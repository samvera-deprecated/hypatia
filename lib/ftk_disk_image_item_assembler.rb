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
  # @param
  # @return
  # @example
  def buildDescMetadata(txt_file)
    
  end
  
  
end