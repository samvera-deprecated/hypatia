# An object to contain all the useful information we can slurp out of a 
#  FTK report for files from a media (e.g. disk) 
class FtkFile
  
  # The filename of the file. Not necessarily unique
  attr_accessor :filename
  # The id number assigned by FTK (e.g. 1004)
  attr_accessor :id
  # The size of the file, in bytes (e.g. 3482 B)
  attr_accessor :filesize 
  # The type of the file (e.g., "WordPerfect 5.1")
  attr_accessor :filetype
  # The path of the file when FTK processed it (e.g., "CM117.001/NONAME [FAT12]/[root]/NATHIN32")
  attr_accessor :filepath
  # The name of the disk image where this file was stored (e.g., "CM117")
  attr_accessor :disk_image_name
  # The date of the file's creation, as reported by FTK
  attr_accessor :file_creation_date
  # The file's last accessed date, as reported by FTK
  attr_accessor :file_accessed_date
  # The file's last modified date, as reported by FTK
  attr_accessor :file_modified_date
  # The file's title, if known (e.g., "The Burgess Shale and the Nature of History")
  attr_accessor :title
  # Did FTK determine that this was a duplicate file? Duplicate files are detected
  # by comparing their checksums. If a duplicate is discovered, the first file that
  # FTK encounters is marked with an 'M' and the second file is marked with a 'D'. If
  # the file is not a duplicate, this value will be empty.
  attr_accessor :duplicate
  # Is the use of this file restricted? (e.g., "False")
  attr_accessor :restricted
  # The md5 checksum of this file (e.g., "4E1AA0E78D99191F4698EEC437569D23")
  attr_accessor :md5
  # The sha1 checksum of this file (e.g., "B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C")
  attr_accessor :sha1
  # The location where FTK put this file after processing (e.g., "files/gould_407_linages_10_characters.txt")
  attr_reader   :export_path
  # The filename part of :export_path. Occasionally this is different from plain old :filename
  attr_reader   :destination_file
  # the mimetype of the file.  Computed from the file extension, or if no extension, by using ruby-filemagic
  attr_reader   :mimetype
  
  # the following attributes are populated from "labels" in the Ftk report.

  # The medium of the file's storage (e.g., "5.25 inch Floppy Disks")
  attr_accessor :medium
  # The access rights for the file (e.g., "Public")
  attr_accessor :access_rights
  # The type of file, if known (e.g., "Journal Article")
  attr_accessor :type
  
  # NOTE: these fields turned up when loading files into the hypatia app
  attr_accessor :event
  attr_accessor :subject
  attr_accessor :organization
  
  def initialize(args = {})
  end
  
  # Whenever we set the value of @export_path, also set the value of @destination_file
  # @param [String] m # The location where FTK put this file after processing (e.g., "/path/to/filename.txt") 
  def export_path=(m)
    @export_path = m
    a = m.split('/')
    if (a.length == 1)
      @destination_file = m
    else
      @destination_file = a.last
    end
  end
  
  # We want to have something meaningful for the item title. If there isn't a title, use the file name or the file type. 
  # @return [String]
  def title
    return @title if @title
    return @filename if @filename
    return @type if @type
    return "Unknown file name"
  end
  
  # Given a filename, what will the display derivative filename be?
  # @example 
  #  ftk = FtkFile.new
  #  ftk.filename="NATHIN40.WPD"
  #  ftk.display_deriv_filename
  #  => NATHIN40.htm
  def display_deriv_fname
    tokens = @filename.split('.')
    if tokens.length > 1
      return "#{tokens[0]}.htm"
    else
      return "#{@filename}.htm"
    end
  end

  # Determine the mimetype from the file extension.  If there is no file extension, compute it from the file itself using ruby-filemagic
  # @return [String] the mimetype of the file, as a string
  def mimetype
    mtype = MIME::Types.of(@filename).first
    if (mtype)
      mimetype = MIME::Type.simplified(mtype)
    end
    mimetype
  end

end