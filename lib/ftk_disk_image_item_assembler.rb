require "rubygems"
require "active-fedora"

class FtkDiskImageItemAssembler 
  
  attr_accessor :disk_image_files_dir   # The directory containing the disk images
  attr_accessor :computer_media_photos_dir # The directory containing photos of the physical media (e.g., floppy disks)
  attr_reader :filehash # The hash were we store the files we're processing
  
  def initialize(args)
    @logger = Logger.new('log/ftk_disk_image_item_assembler.log')
    @logger.debug 'Initializing Hypatia FTK Disk Image Object Assembler'
    
    raise "Can't find directory #{args[:disk_image_files_dir]}" unless File.directory? args[:disk_image_files_dir]
    @disk_image_files_dir = args[:disk_image_files_dir]
    raise "Can't find directory #{args[:computer_media_photos_dir]}" unless File.directory? args[:computer_media_photos_dir]
    @computer_media_photos_dir = args[:computer_media_photos_dir]
    @filehash = {}
    build_file_hash
  end
  
  # Create fedora objects out of the ftk disk image files
  def process
    @filehash.each { |disk|
      fdi = FtkDiskImage.new(:txt_file => disk[1][:txt])  
      if File.file? fdi.txt_file
        obj = build_object(fdi)
        # puts obj.pid
      else
        @logger.error "Couldn't find txt file #{fdi.txt_file}"
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
      
      # If filehash doesn't have a space for this disk number yet, make one
      if @filehash[disk_number.to_sym] == nil
        @filehash[disk_number.to_sym] = {}
      end
      file_extension = file.split('/').last.split('.').last
      if file_extension == 'csv' 
        @filehash[disk_number.to_sym][:csv] = file
      elsif file_extension == 'txt' 
        @filehash[disk_number.to_sym][:txt] = file
      else
        @filehash[disk_number.to_sym][:dd] = file
      end
    }
  end
  
  # Extract descMetadata info from the EAD file
  # @param [FtkDiskImage] fdi
  # @return [Nokogiri::XML::Document]
  def buildDescMetadata(fdi)
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
  
  # Calculate the file size of the disk image file 
  # @param [FtkDiskImage] fdi
  # @return [String]
  def calculate_dd_size(fdi)
    bytes = File.size(@filehash[fdi.disk_number.to_sym][:dd])
    "#{bytes} B"
  end
  
  # Build the contentMetadata 
  # @param [FtkDiskImage] fdi
  # @return [Nokogiri::XML::Document]
  def buildContentMetadata(fdi,pid,file_asset_pid)
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
  
  # Build rightsMetadata datastream
  # @return [Nokogiri::XML::Document]
  def buildRightsMetadata
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
  
  # Build fedora objects for a disk image
  # @param [FtkDiskImage] fdi
  # @return [HypatiaDiskImageItem]
  def build_object(fdi)
    hypatia_disk_image_item = HypatiaDiskImageItem.new
    hypatia_disk_image_item.save
    dd_file = create_dd_file_asset(hypatia_disk_image_item,fdi)
    build_ng_xml_datastream(hypatia_disk_image_item, "descMetadata", buildDescMetadata(fdi))
    build_ng_xml_datastream(hypatia_disk_image_item, "contentMetadata", buildContentMetadata(fdi,hypatia_disk_image_item.pid,dd_file.pid))
    build_ng_xml_datastream(hypatia_disk_image_item, "rightsMetadata", buildRightsMetadata)
    # puts hypatia_disk_image_item.pid
    return hypatia_disk_image_item
  end
  
  # Create a FileAsset to hold the dd file
  # @param [HypatiaDiskImageItem] hypatia_disk_image_item
  # @param [FtkDiskImage] fdi
  # @return [FileAsset]
  def create_dd_file_asset(hypatia_disk_image_item,fdi)
    dd_file = FileAsset.new
    dd_file.add_relationship(:is_part_of,hypatia_disk_image_item)
    file = File.new(@filehash[fdi.disk_number.to_sym][:dd])
    dd_file.add_file_datastream(file)
    add_photos_to_dd_file_asset(dd_file,fdi)
    dd_file.save
    return dd_file
  end
  
  # Add any photos of the physical media as datastreams attached to the disk image FileAsset
  # @param [FileAsset] dd_file
  # @param [FtkDiskImage] fdi
  # @return [FileAsset]
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