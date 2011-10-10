require "rubygems"
require "active-fedora"
require "digest/md5"
require "digest/sha1"

# Creates disk image item objects in Fedora, based on disk images files in a directory, the parent collection object's fedora pid, and a directory (possibly empty???) containing photos of the disks.
class FtkDiskImageItemAssembler 
  
  # The directory containing the disk images
  attr_accessor :disk_image_files_dir
  # The directory containing photos of the physical media (e.g., floppy disks)
  attr_accessor :computer_media_photos_dir
  # What collection are these files part of?
  attr_accessor :collection_pid
  # A hash where we store the files we're processing
  attr_reader :filehash
  
  def initialize(args)
    @logger = Logger.new('log/ftk_disk_image_item_assembler.log')
    @logger.debug 'Initializing Hypatia FTK Disk Image Item Object Assembler'
    
    raise "Can't find directory #{args[:disk_image_files_dir]}" unless File.directory? args[:disk_image_files_dir]
    @disk_image_files_dir = args[:disk_image_files_dir]
    raise "Can't find directory #{args[:computer_media_photos_dir]}" unless File.directory? args[:computer_media_photos_dir]
    @computer_media_photos_dir = args[:computer_media_photos_dir]
    @collection_pid = args[:collection_pid]
    
    @filehash = {}
    build_file_hash
  end
  
  # Create fedora objects out of the ftk disk image files
  def process
    @filehash.each { |disk|
      if (disk[1][:txt] and File.file? disk[1][:txt])
        fdi = FtkDiskImage.new(:txt_file => disk[1][:txt])  
        obj = build_object(fdi)
      else 
        # If we don't have a .txt file describing this disk, 
        # just record the disk number and add the FileAsset
        fdi = FtkDiskImage.new()
        # TODO:  When we don't have a .txt file describing a disk, will we need to extrapolate the disk number from the filepath?
        fdi.disk_number = disk[0].to_s
        fdi.disk_type = "unknown"
        fdi.md5 = "unknown"
        fdi.sha1 = "unknown"
        @logger.error "Couldn't find txt file for #{disk[1][:dd]}"
        obj = build_object(fdi)
      end
    }
  end
  
  
  # Read in all the files in @disk_image_files_dir.
  # Determine which of these are dd files (the actual disk image),
  # and which are .csv and .txt metadata about the disk image.
  # Load these into a hash for easy access as we're building the fedora objects.
  # We assume that there are only three files for each disk image: 
  # .txt, .csv, and the disk image, which may end in .dd or not
  # @return [Hash]
  def build_file_hash
    Dir["#{@disk_image_files_dir}/*"].each { |file|
      disk_number = file.split('/').last.split('.').first
      
      # if disk_number contains a space, take the part after the space
      disk_number = disk_number.split(' ').last
      disk_number_sym = disk_number.to_sym
      
      # If filehash doesn't have a space for this disk number yet, make one
      if @filehash[disk_number_sym] == nil
        @filehash[disk_number_sym] = {}
      end
      file_extension = file.split('/').last.split('.').last
      if file_extension == 'csv' 
        @filehash[disk_number_sym][:csv] = file
      elsif file_extension == 'txt' 
        @filehash[disk_number_sym][:txt] = file
      else
        @filehash[disk_number_sym][:dd] = file
      end
    }
  end
  
  # Build fedora objects for a disk image
  # @param [FtkDiskImage] fdi
  # @return [HypatiaDiskImageItem]
  def build_object(fdi)
    hypatia_disk_image_item = HypatiaDiskImageItem.new
    hypatia_disk_image_item.label="#{fdi.disk_type} #{fdi.disk_number}"
    hypatia_disk_image_item.add_relationship(:is_member_of_collection, @collection_pid)
    hypatia_disk_image_item.save
    dd_file = create_dd_file_asset(hypatia_disk_image_item, fdi)
    build_ng_xml_datastream(hypatia_disk_image_item, "descMetadata", build_desc_metadata(fdi))
# FIXME:  need new code here!    
#    build_ng_xml_datastream(hypatia_disk_image_item, "contentMetadata", build_content_metadata(fdi,hypatia_disk_image_item.pid,dd_file.pid))
    build_ng_xml_datastream(hypatia_disk_image_item, "rightsMetadata", build_rights_metadata)
    hypatia_disk_image_item.save
    return hypatia_disk_image_item
  end

  # Extract descMetadata info for HypatiaDiskImageItem from the EAD file.  It should adhere to the 
  #   mods xml expected by model HypatiaDiskImgDescMetadataDS
  # @param [FtkDiskImage] fdi
  # @return [Nokogiri::XML::Document] - the xmlContent for the descMetadata datastream
  def build_desc_metadata(fdi)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods('xmlns:mods' => "http://www.loc.gov/mods/v3") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        xml['mods'].titleInfo {
          xml['mods'].title_ fdi.disk_number
        }
        xml['mods'].physicalDescription {
          xml['mods'].extent fdi.disk_type
          xml['mods'].digitalOrigin "Born Digital"
        }
        xml['mods'].identifier("type"=>"local"){
          xml.text fdi.disk_number
        }
      }
    end
    builder.to_xml
  end
  
  # Build the contentMetadata for HypatiaDiskImageItem as an xml object.  it should adhere to the 
  #  xml expected by model HypatiaDiskImgContentMetadataDS
  # @param [FtkDiskImage] fdi
  # @return [Nokogiri::XML::Document] - the xmlContent for the contentMetadata datastream
  # @deprecated
  def build_content_metadata(fdi,pid,file_asset_pid)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.contentMetadata("type" => "born-digital", "objectId" => pid) {
        xml.resource("id" => "disk-image", "type" => "disk-image", "data" => "content", "objectId" => file_asset_pid){
          xml.file("id" => fdi.disk_number, "format" => "BINARY", "size" => calculate_dd_size(fdi) ) {
            xml.checksum("type" => "md5") {
              xml.text fdi.md5
            }
          }
        }
      }
    end    
    builder.to_xml
  end

#   # Build the contentMetadata for HypatiaDiskImageItem as an xml object.  it should adhere to the 
  #  xml expected by model HypatiaDiskImgContentMetadataDS
  # @param [FtkDiskImage] the intermediate object for the FTK Disk Image that is being turned into a Fedora object
  # @param [String] the Fedora pid of the DiskImageItem object
  # @param [ActiveFedora::FileAsset] the FileAsset object for the disk image file itself
  # @param [Array] an array the FileAsset objects for the photos of the disk media
  # @return [Nokogiri::XML::Document] - the xmlContent for the contentMetadata datastream
  def build_content_metadata(fdi, dii_pid, dd_file_asset, photo_file_asset_array)
    builder = Nokogiri::XML::Builder.new do |xml|
      dd_file_datastream_name = dd_file_asset.datastreams.keys.select {|k| k !~ /(DC|RELS\-EXT|descMetadata)/}.first
      dd_file_datastream = dd_file_asset.datastreams[dd_file_datastream_name]
      xml.contentMetadata("type" => "file", "objectId" => dii_pid) {
        # FileAsset for disk image itself
        xml.resource("id" => dd_file_datastream.label, "type" => "media-file", "objectId" => dd_file_asset.pid){
          xml.file("id" => dd_file_datastream.label, "format" => "BINARY", "mimetype" => dd_file_datastream.mime_type, 
                    "size" => File.size(@filehash[fdi.disk_number.to_sym][:dd]), "preserve" => "yes", "publish" => "yes", "shelve" => "yes" ) {
            xml.location("type" => "datastreamID") {
              xml.text dd_file_datastream.dsid
            }
            xml.checksum("type" => "md5") {
              xml.text fdi.md5
            }
            xml.checksum("type" => "sha1") {
              xml.text fdi.sha1
            }
          }
        }
        # FileAssets for photos
        photo_file_asset_array.each { |photo_file_asset|  
          ds_name = photo_file_asset.datastreams.keys.select {|k| k !~ /(DC|RELS\-EXT|descMetadata)/}.first
          ds = photo_file_asset.datastreams[dd_file_datastream_name]
          xml.resource("id" => ds.label, "type" => "image-front", "objectId" => photo_file_asset.pid){
            xml.file("id" => ds.label, "format" => "JPG", "mimetype" => ds.mime_type, 
                      "size" => File.size(ds.blob), "preserve" => "yes", "publish" => "yes", "shelve" => "yes" ) {
              xml.location("type" => "datastreamID") {
                xml.text ds.dsid
              }
              xml.checksum("type" => "md5") {
                xml.text Digest::MD5.hexdigest(ds.blob.read)
              }
              xml.checksum("type" => "sha1") {
                xml.text Digest::SHA1.hexdigest(ds.blob.read)
              }
            }
          }
        } # photo_file_asset_array
      } # xml.contentMetadata
    end # builder
    builder.to_xml
  end
  
  # Build rightsMetadata datastream  for HypatiaDiskImageItem;  discover and read permissions allowed for all.
  # @return [Nokogiri::XML::Document] - the xmlContent for the rightsMetadata datastream
  def build_rights_metadata
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.rightsMetadata("xmlns" => "http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1", "version" => "0.1"){
        xml.access("type" => "discover"){
          xml.machine {
            xml.group "public"
          }
        }
        xml.access("type" => "read"){
          xml.machine {
            xml.group "public"
          }
        }
      }
    end
    builder.to_xml
  end
  
  # Create a FileAsset to hold the dd file, save it, and connect it to the HypatiaDiskImageItem
  # @param [HypatiaDiskImageItem] hypatia_disk_image_item - the FileAsset objects created will have _is_part_of relationships to the object in this param
  # @param [FtkDiskImage] fdi - has been populated per the FTK produced .txt file, if we have one
  # @return [FileAsset] object for the disk image object
  def create_dd_file_asset(hypatia_disk_image_item, fdi)
    dd_file_asset = FileAsset.new
    # the label value ends up in DC dc:title and descMetadata  title ??
    dd_file_asset.label="FileAsset for FTK disk image #{fdi.disk_type} #{fdi.disk_number}"
    dd_file_asset.add_relationship(:is_part_of, hypatia_disk_image_item)
    
    # For now, only add the dd file for the Xanadu collection, since other dd files are not for public viewing
    if @collection_pid =~ /(xanadu|fixture)/
      file = File.new(@filehash[fdi.disk_number.to_sym][:dd])
      dd_file_asset.add_file_datastream(file, {:mimeType => "application/octet-stream", :label => fdi.disk_number})
    end
    
    dd_file_asset.save
    dd_file_asset
  end
  
  # Calculate the file size of the disk image file 
  # @param [FtkDiskImage] fdi
  # @return [String]
  # @deprecated
  def calculate_dd_size(fdi)
    bytes = File.size(@filehash[fdi.disk_number.to_sym][:dd])
    "#{bytes} B"
  end
  
# TODO:  remove this  
  # Add any photos of the physical media as datastreams attached to the disk image FileAsset
  # @param [FileAsset] dd_file
  # @param [FtkDiskImage] fdi
  # @return [FileAsset]
  # @deprecated
  def add_photos_to_dd_file_asset(dd_file,fdi)
    image_path_base = "#{@computer_media_photos_dir}/#{fdi.disk_number}"
    image_hash = {"#{image_path_base}.JPG" => "front", "#{image_path_base}_1.JPG" => "front", "#{image_path_base}_2.JPG" => "back"}
    image_hash.each_pair { |image_file, label|
      if File.file? image_file
        f = File.new(image_file)
        image_ds =  ActiveFedora::Datastream.new(:dsID => label, :dsLabel => "#{label.capitalize} image for #{fdi.disk_type} #{fdi.disk_number}", :controlGroup => 'M', :blob => f)
        dd_file.add_datastream(image_ds)
      else
        @logger.warn "Couldn't find expected media photo file #{image_file}"
      end
    }
    dd_file.save
    dd_file
  end
  
  # Create FileAsset objects for photo images of the disk, save them, and connect them to the HypatiaDiskImageItem
  # @param [HypatiaDiskImageItem] hypatia_disk_image_item - the FileAsset objects created will have _is_part_of relationships to the object in this param
  # @param [FtkDiskImage] fdi - has been populated per the FTK produced .txt file, if we have one
  # @return [Array] of FileAsset objects for the photo images of the disk
  def create_photo_file_assets(hypatia_disk_image_item, fdi)
    photo_file_assets = []
    photo_path_base = "#{@computer_media_photos_dir}/#{fdi.disk_number}"
    photo_filenames = ["#{photo_path_base}.JPG", "#{photo_path_base}_1.JPG", "#{photo_path_base}_2.JPG"]
    photo_filenames.each { |photo_fname|
      if File.file? photo_fname
        photo_fa = FileAsset.new
        # the label value ends up in DC dc:title and descMetadata  title ??
        photo_fa.label="FileAsset for photo of FTK disk image #{fdi.disk_number}"
        photo_fa.add_relationship(:is_part_of, hypatia_disk_image_item)

        file = File.new(photo_fname)
        photo_fa.add_file_datastream(file, {:label => File.basename(file.path), :mimeType => "image/jpeg"})
        photo_fa.save
        photo_file_assets << photo_fa
#      else
#        @logger.warn "Couldn't find expected media photo file #{image_file}"
      end
    }
    photo_file_assets
  end
  
  
  # Create a Nokogiri XML Datastream on the HypatiaDiskImageItem object
  # @param [HypatiaDiskImageItem] the HypatiaDiskImageItem object getting the datastream
  # @param [String] the name of the datastream (must correspond to ActiveFedora model name for datastream)
  # @param [String] string to be parsed as a Nokogiri XML Document
  def build_ng_xml_datastream(item, dsname, xml)
    ds = item.datastreams[dsname]
    ds.content = xml
    ds.ng_xml = Nokogiri::XML::Document.parse(xml)
    ds.dirty = true
    ds.save
  end
  
end