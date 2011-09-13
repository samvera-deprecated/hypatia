require "rubygems"
require "active-fedora"

class FtkDiskImageItemAssembler 
  
  attr_accessor :disk_image_files_dir   # The directory containing the disk images
  attr_reader :filehash # The hash were we store the files we're processing
  
  def initialize(args)
    raise "Can't find directory #{args[:disk_image_files_dir]}" unless File.directory? args[:disk_image_files_dir]
    @disk_image_files_dir = args[:disk_image_files_dir]
    @filehash = {}
    build_file_hash
    # build_objects
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
  
end