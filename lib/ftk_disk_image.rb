require "rubygems"
require "active-fedora"

class FtkDiskImage
  
  attr_accessor :txt_file             # The txt file produced by FTK that contains the 
                                      # metadata about this disk image
  attr_reader :disk_number            # The number used to identify this disk
  attr_reader :disk_type              # The kind of disk this was (e.g., "5.25 inch Floppy Disk")
  attr_reader :md5                    # The md5 checksum for the disk image
  
  def initialize(args = {})
    raise exception "Please pass :txt_file so I have a metadata source" unless args[:txt_file]
    raise exception "Can't find txt file #{args[:txt_file]}" unless File.file? args[:txt_file]
    @txt_file = args[:txt_file]
    process_file
  end
  
  # Go through the .txt file and extract the useful information
  def process_file
    lines_array = open(@txt_file) { |f| f.readlines }
    lines_array.each_with_index{|line, index| 
      case line
      when /Evidence Number/
        @disk_number = get_disk_number(line)
      when /Notes/
        @disk_type = get_disk_type(line)
      when /MD5/
        @md5 ||= get_md5(line)
      end
    }
  end
  
  # Take a String that looks like "Evidence Number: CM006" and extract the
  # @param [String] line
  # @return [String]
  def get_disk_number(line)
    line.split(': ').last.strip
  end
  
  # Extract the kind of disk this was (e.g., "5.25 inch Floppy Disk")
  # @param [String] line
  # @return [String]
  def get_disk_type(line)
    line.split(': ').last.strip
  end
  
  # Extract the md5 value
  # @param [String] line
  # @return [String]
  def get_md5(line)
    line.split(': ').last.strip
  end
  
end