# An object to contain all the useful information we can slurp out of a 
#  FTK produced .txt file that corresponds to an FTK produced disk image file 
class FtkDiskImage
  
  # The txt file produced by FTK that contains the metadata about this disk image
  attr_accessor :txt_file
  # The number used to identify this disk (essentially, the filename for the disk image) (e.g. CM004)
  attr_accessor :disk_name
  # An assigned "case number", akin to a call number (e.g. M1437)
  attr_accessor :case_number
  # The kind of disk this was (e.g., "5.25 inch Floppy Disk")
  attr_accessor :disk_type
  # The md5 checksum for the disk image
  attr_accessor :md5
  # The sha1 checksum for the disk image
  attr_accessor :sha1
  
  def initialize(ftk_txt_file)
    if ftk_txt_file
      raise "Can't find txt file #{ftk_txt_file}" unless File.file? ftk_txt_file
      @txt_file = ftk_txt_file
      process_file
    end
  end
  
  # Go through the .txt file and extract the useful information
  def process_file
    lines_array = open(@txt_file) { |f| f.readlines }
    lines_array.each_with_index{|line, index| 
      case line
      when /Evidence Number/
        @disk_name = get_value_after_colon(line)
      when /Case Number/
        @case_number = get_value_after_colon(line)
      when /Notes/
        @disk_type = get_value_after_colon(line)
      when /MD5/
        @md5 ||= get_value_after_colon(line)
      when /SHA1/
        @sha1 ||= get_value_after_colon(line)
      end
    }
  end

  # Take a String that looks like "Evidence Number: CM006" and return the value after the colon (without leading space)
  # @param [String] line
  # @return [String] value after the colon (e.g. "CM006")
  def get_value_after_colon(line)
    line.split(': ').last.strip
  end
  
end