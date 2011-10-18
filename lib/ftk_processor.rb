# Given the xml report file produced by FTK when individual files are extracted from a disk image, populate this object with information about each file and the collection title, call number and series
class FtkProcessor
  
  # location of the xml report from FTK (from which we get all the info)
  attr_accessor :ftk_report
  # name of the collection
  attr_reader :collection_title
  # call number of the collection
  attr_reader :call_number
  # series of the collection
  attr_reader :series
  # an array of FtkFile objects to use to create HypatiaFtkItem fedora objects
  attr_reader :files

# TODO:  could make the args positional, rather than a hash
  # Initialize an FTKProcessor object. 
  # If you don't pass in any arguments, it won't do anything, and you'll need to manually set the FTK report location and run
  # "process_ftk_report" yourself.
  # For fastest processing, pass the location of the ftk report in at initialization time
  # @param [Hash] you can pass in a value for :logfile and for :ftk_report in this hash.  :logfile will default to "log/ftk_processor.log"
  # @example instantiating with an FTK report
  #  ftkp = FtkProcessor.new(:ftk_report => "/path/to/FTK_report.xml", :logfile => "log/ftk_processor.log")
  def initialize(args = {})
    @files = []

    if args[:logfile]
      @logger = args[:logfile]
    else
      @logger = Logger.new('log/ftk_processor.log')
    end
    
    if args[:ftk_report]
      raise "Can't find file #{args[:ftk_report]}" unless File.file? args[:ftk_report]
      @ftk_report = args[:ftk_report]
    end
    @doc = Nokogiri::XML(File.open(@ftk_report)) if @ftk_report
    process_ftk_report if @doc
  end
  
  # Extract data from the ftk xml report
  def process_ftk_report
    @logger.debug("Processing FTK report #{@ftk_report}")
    get_title_and_call_number
    get_series
    get_file_descriptions
  end
  
  # get the collection title and call number from a fun place in the FTK Report xml file
  def get_title_and_call_number
    text = @doc.xpath("//fo:page-sequence[2][fo:flow/fo:block[text()='Case Information']]/fo:flow/fo:table[1]/fo:table-body/fo:table-row[3]/fo:table-cell[2]/fo:block/text()")
    split_text = text.to_s.partition(" ")
    @collection_title = split_text[2]
    @call_number = split_text[0]
  end
  
  # get the series for these files from a fun place in the FTK Report xml file
  def get_series
    @series = @doc.xpath("//fo:page-sequence[1][fo:flow/fo:block[text()='Case Information']]/fo:flow/fo:block[7]/text()").to_s.gsub(/\s/, ' ').squeeze(" ").strip
  end

  # populate the @files Array with FtkFile objects corresponding to the file descriptions in the FTK report xml.
  def get_file_descriptions
    file_node_set = @doc.xpath("//fo:table-body[fo:table-row/fo:table-cell/fo:block[text()='File Comments']]")
    file_node_set.each do |file_node|
      process_file_node(file_node)
    end
  end
  
  # Process a single file description node from the FTK Report, putting the 
  #  resulting FtkFile object into the @files Array
  # @param [Nokogiri::XML::Node] a Node object corresponding to a single file inthe FTK report
  def process_file_node(node)
    ff = FtkFile.new
    ff.filename = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Name']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.id = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Item Number']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.filesize = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Logical Size']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.filetype = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='File Type']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.filepath = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Path']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.disk_image_name = ff.filepath.slice(0,5)
    ff.file_creation_date = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Created Date']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.file_accessed_date = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Accessed Date']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.file_modified_date = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Modified Date']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.md5 = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='MD5 Hash']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.sha1 = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='SHA1 Hash']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.export_path = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Exported as']]/fo:table-cell[2]/fo:block/fo:basic-link/@external-destination").to_s
    ff.duplicate = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Duplicate File']]/fo:table-cell[2]/fo:block/text()").to_s
    ff.restricted = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Flagged Privileged']]/fo:table-cell[2]/fo:block/text()").to_s

    getLabels(node,ff)

    @files.push(ff)
  end

  # Extract the labels attached to a file and split them apart, adding each label field to the ff object
  # The FTK report stores them like this:
  # [access_rights]Public,[medium]3.5 inch Floppy Disks,[type]Natural History Magazine Column 
  # @param [Nokogiri::XML::Node] node
  # @param [FtkFile] The FtkFile object to receive the label fields and their values
  def getLabels(node, ff)
    label_hash = {}
    labels = node.xpath("fo:table-row[fo:table-cell/fo:block[text()='Label']]/fo:table-cell[2]/fo:block/text()").to_s
    
    if labels and labels =~ /\[/
      labels.split(',[').each do |pair|
        key = pair.split(']')[0].gsub('[','')
        value = pair.split(']')[1].strip
        ff.send("#{key}=".to_sym, value.gsub(/\s/, ' ').squeeze(" ").strip)
      end
    end
  end
  
end