#require "rubygems"
#require "active-fedora"
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
  # A hash where we store the files we're processing where the key of the hash is a symbol for the name of the disk (e.g. :CM004) 
  #   and the value of the hash is itself a hash with possible keys of :txt, :csv, :dd and the values are the file paths
  # e.g.:
  #{ :CM004=>{
  #    :txt=>"../data/gould/M1437 Gould/Disk Image/CM004.001.txt", 
  #    :dd=>"../data/gould/M1437 Gould/Disk Image/CM004.001", 
  #    :csv=>"../data/gould/M1437 Gould/Disk Image/CM004.001.csv"
  #    }, 
  #  :CM005=>{
  #    :txt=>"../data/gould/M1437 Gould/Disk Image/CM005.001.txt", 
  #    :dd=>"../data/gould/M1437 Gould/Disk Image/CM005.001", 
  #    :csv=>"../data/gould/M1437 Gould/Disk Image/CM005.001.csv"
  #   }
  # }
  attr_reader :files_hash
  
  def initialize(args)
    @logger = Logger.new('log/ftk_disk_image_item_assembler.log')
    @logger.debug 'Initializing Hypatia FTK Disk Image Item Object Assembler'
    
    raise "Can't find directory #{args[:disk_image_files_dir]}" unless File.directory? args[:disk_image_files_dir]
    @disk_image_files_dir = args[:disk_image_files_dir]
    raise "Can't find directory #{args[:computer_media_photos_dir]}" unless File.directory? args[:computer_media_photos_dir]
    @computer_media_photos_dir = args[:computer_media_photos_dir]
    @collection_pid = args[:collection_pid]
    
    @files_hash = {}
    build_files_hash
  end

  
  # Create fedora objects out of the ftk disk image files
  def process
    @files_hash.each { |disk_sym, disk_file_hash|
      if (disk_file_hash[:txt] and File.file? disk_file_hash[:txt])
        fdi = FtkDiskImage.new(disk_file_hash[:txt])  
        obj = build_object(fdi)
      else 
        # If we don't have a .txt file describing this disk, 
        # just record the disk number and add the FileAsset
        fdi = FtkDiskImage.new(nil)
        fdi.disk_name = disk_sym.to_s
        fdi.case_number = ""
        fdi.disk_type = ""
        fdi.md5 = ""
        fdi.sha1 = ""
        @logger.warn "Couldn't find txt file for #{disk_file_hash[:dd]}"
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
  # @return [Hash] where the key of the hash is a symbol for the name of the disk (e.g. :CM004) 
  #   and the value of the hash is itself a hash with possible keys of :txt, :csv, :dd and the values are the file paths
  # e.g.:
  #{ :CM004=>{
  #    :txt=>"../data/gould/M1437 Gould/Disk Image/CM004.001.txt", 
  #    :dd=>"../data/gould/M1437 Gould/Disk Image/CM004.001", 
  #    :csv=>"../data/gould/M1437 Gould/Disk Image/CM004.001.csv"
  #    }, 
  #  :CM005=>{
  #    :txt=>"../data/gould/M1437 Gould/Disk Image/CM005.001.txt", 
  #    :dd=>"../data/gould/M1437 Gould/Disk Image/CM005.001", 
  #    :csv=>"../data/gould/M1437 Gould/Disk Image/CM005.001.csv"
  #   }
  # }
  def build_files_hash
    Dir["#{@disk_image_files_dir}/*"].each { |filename|
      disk_name = filename.split('/').last.split('.').first
      # if disk_name contains a space, take the part after the space
      disk_name = disk_name.split(' ').last
      disk_name_sym = disk_name.to_sym

      @files_hash[disk_name_sym] ||= {}
      case File.extname(filename)
        when '.csv'
          @files_hash[disk_name_sym][:csv] = filename
        when '.txt'
          @files_hash[disk_name_sym][:txt] = filename
        else 
          @files_hash[disk_name_sym][:dd] = filename
      end
    }
  end
  
  # Build fedora objects for a disk image
  # @param [FtkDiskImage] fdi
  # @return [HypatiaDiskImageItem]
  def build_object(fdi)
    hypatia_disk_image_item = HypatiaDiskImageItem.new
    hypatia_disk_image_item.add_relationship(:is_member_of_collection, @collection_pid)
    hypatia_disk_image_item.save
    build_ng_xml_datastream(hypatia_disk_image_item, "descMetadata", build_desc_metadata(fdi))
    build_ng_xml_datastream(hypatia_disk_image_item, "rightsMetadata", build_rights_metadata)
    dd_file_asset = create_dd_file_asset(hypatia_disk_image_item, fdi)
    photo_file_asset_array = create_photo_file_assets(hypatia_disk_image_item, fdi)
    content_md_xml = build_content_metadata(fdi, @collection_pid, dd_file_asset, photo_file_asset_array)
    build_ng_xml_datastream(hypatia_disk_image_item, "contentMetadata", content_md_xml)
    hypatia_disk_image_item.save
    return hypatia_disk_image_item
  end


  # Create a FileAsset to hold the dd file, save it, and connect it to the HypatiaDiskImageItem
  # @param [HypatiaDiskImageItem] hypatia_disk_image_item - the FileAsset objects created will have _is_part_of relationships to the object in this param
  # @param [FtkDiskImage] fdi - has been populated per the FTK produced .txt file, if we have one
  # @return [FileAsset] object for the disk image object
  def create_dd_file_asset(hypatia_disk_image_item, fdi)
    dd_file_asset = FileAsset.new
    # the label value ends up in DC dc:title and descMetadata  title ??
    dd_file_asset.label="FileAsset for FTK disk image #{fdi.disk_type} #{fdi.disk_name}"
    dd_file_asset.add_relationship(:is_part_of, hypatia_disk_image_item)

    # For now, only add the dd file for the Xanadu collection, since other dd files are not for public viewing
    if @collection_pid =~ /(xanadu|fixture)/
      file = File.new(@files_hash[fdi.disk_name.to_sym][:dd])
      dd_file_asset.add_file_datastream(file, {:mimeType => "application/octet-stream", :label => fdi.disk_name})
    end

    dd_file_asset.save
    dd_file_asset
  end

  # Create FileAsset objects for photo images of the disk, save them, and connect them to the HypatiaDiskImageItem
  # @param [HypatiaDiskImageItem] hypatia_disk_image_item - the FileAsset objects created will have _is_part_of relationships to the object in this param
  # @param [FtkDiskImage] fdi - has been populated per the FTK produced .txt file, if we have one
  # @return [Array] of FileAsset objects for the photo images of the disk
  def create_photo_file_assets(hypatia_disk_image_item, fdi)
    photo_file_assets = []
    photo_path_base = "#{@computer_media_photos_dir}/#{fdi.disk_name}"
    photo_filenames = ["#{photo_path_base}.JPG", "#{photo_path_base}_1.JPG", "#{photo_path_base}_2.JPG"]
    photo_filenames.each { |photo_fname|
      if File.file? photo_fname
        photo_fa = FileAsset.new
        # the label value ends up in DC dc:title and descMetadata  title ??
        photo_fa.label="FileAsset for photo of FTK disk image #{fdi.disk_name}"
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


  # Extract descMetadata info for HypatiaDiskImageItem from the passed FTKDiskImage object.  
  #   The descMetadata must adhere to the mods xml expected by model HypatiaDiskImgDescMetadataDS
  # @param [FtkDiskImage] object containing the information extracted from the .txt file produced by FTK processing of a disk
  # @return [Nokogiri::XML::Document] - the xmlContent for the descMetadata datastream
  def build_desc_metadata(fdi)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods('xmlns:mods' => "http://www.loc.gov/mods/v3") {
        xml['mods'].titleInfo {
          xml['mods'].title_ fdi.disk_name
        }
        xml['mods'].physicalDescription {
          xml['mods'].extent fdi.disk_type
          xml['mods'].digitalOrigin "Born Digital"
        }
        xml['mods'].identifier("type"=>"local"){
          xml.text fdi.case_number
        }
      }
    end
    builder.to_xml
  end

  # Build rightsMetadata datastream  for HypatiaDiskImageItem;  discover and read permissions allowed for all, edit permissions for archivist group
  # @return [Nokogiri::XML::Document] - the xmlContent for the rightsMetadata datastream
  def build_rights_metadata
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.rightsMetadata("xmlns" => "http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1", "version" => "0.1"){
        xml.access("type" => "discover") {
          xml.machine {
            xml.group "public"
          }
        }
        xml.access("type" => "read") {
          xml.machine {
            xml.group "public"
          }
        }
        xml.access("type" => "edit") {
          xml.machine {
            xml.group "archivist"
          }
        }
      }
    end
    builder.to_xml
  end
  
  # Build the contentMetadata for HypatiaDiskImageItem as an xml object.  it should adhere to the 
  #  xml expected by model HypatiaDiskImgContentMetadataDS
  # @param [FtkDiskImage] the intermediate object for the FTK Disk Image that is being turned into a Fedora object
  # @param [String] the Fedora pid of the HypatiaDiskImageItem object
  # @param [ActiveFedora::FileAsset] the FileAsset object for the disk image file itself
  # @param [Array] an array the FileAsset objects for the photos of the disk media
  # @return [Nokogiri::XML::Document] - the xmlContent for the contentMetadata datastream
  def build_content_metadata(fdi, dii_pid, dd_file_asset, photo_file_asset_array)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.contentMetadata("type" => "file", "objectId" => dii_pid) {
        # FileAsset for disk image itself
        dd_file_ds_name = dd_file_asset.datastreams.keys.select {|k| k !~ /(DC|RELS\-EXT|descMetadata)/}.first
        if (dd_file_ds_name)
          dd_file_ds = dd_file_asset.datastreams[dd_file_ds_name]
          xml.resource("id" => dd_file_ds.label, "type" => "media-file", "objectId" => dd_file_asset.pid){
            xml.file("id" => dd_file_ds.label, "format" => "BINARY", "mimetype" => dd_file_ds.mime_type, 
                      "size" => File.size(dd_file_ds.blob), "preserve" => "yes", "publish" => "yes", "shelve" => "yes" ) {
              xml.location("type" => "datastreamID") {
                xml.text dd_file_ds.dsid
              }
              xml.checksum("type" => "md5") {
                xml.text fdi.md5
              }
              xml.checksum("type" => "sha1") {
                xml.text fdi.sha1
              }
            }
          }
        end
        # FileAssets for photos
        case photo_file_asset_array.size
          when 0
            ;
          when 1
            add_photo_file_asset(xml, photo_file_asset_array[0], "image-front")
          when 2
            add_photo_file_asset(xml, photo_file_asset_array[0], "image-front")
            add_photo_file_asset(xml, photo_file_asset_array[1], "image-back")
          else
            add_photo_file_asset(xml, photo_file_asset_array[0], "image-front")
            add_photo_file_asset(xml, photo_file_asset_array[1], "image-back")
            photo_file_asset_array[2, photo_file_asset_array.size-2].each_with_index { |photo_file_asset, ix|  
              add_photo_file_asset(xml, photo_file_asset_array[ix+2], "image-other" + (ix+1).to_s)
            }
        end
      } # xml.contentMetadata
    end # builder
    builder.to_xml
  end
  
  # Add a <resource> element to the passed Nokogiri::XML::Builder object.
  #  The <resource> element will contain information about the photo FileAsset
  #   object passed in, and will have a type attribute per the resource_type
  #   passed in.
  # @param [Nokogiri::XML::Builder] the object to receive the xml created by this method
  # @param [ActiveFedora::FileAsset] the photo's FileAsset object to be referenced in the newly created xml 
  # @param [String] the string for the type attribute on the <resource> element
  def add_photo_file_asset(xml, photo_file_asset, resource_type)
    ds_name = photo_file_asset.datastreams.keys.select {|k| k !~ /(DC|RELS\-EXT|descMetadata)/}.first
    ds = photo_file_asset.datastreams[ds_name]
    xml.resource("id" => ds.label, "type" => resource_type, "objectId" => photo_file_asset.pid){
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
  end
  
  # Create a Nokogiri XML Datastream on the HypatiaDiskImageItem object.  
  #   Note that the datastream is marked as "dirty" and will not be saved until
  #   the object is saved elsewhere.
  # @param [HypatiaDiskImageItem] the HypatiaDiskImageItem object getting the datastream
  # @param [String] the name of the datastream (must correspond to ActiveFedora model name for datastream)
  # @param [String] string to be parsed as a Nokogiri XML Document
  def build_ng_xml_datastream(item, dsname, xml)
    ds = item.datastreams[dsname]
    ds.content = xml
    ds.ng_xml = Nokogiri::XML::Document.parse(xml)
    ds.dirty = true
  end
  
end