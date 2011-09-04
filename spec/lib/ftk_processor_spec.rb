require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_processor")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require 'rubygems'
require 'ruby-debug'

describe FtkProcessor do
  
  context "basic behavior" do
    it "can instantiate" do
      r = FtkProcessor.new
      r.class.should eql(FtkProcessor)
    end
    
    # it "can accept an FTK XML report as input" do
    #    fixture_location = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
    #    r = FtkProcessor.new(:ftk_report => fixture_location)
    #    r.ftk_report.should eql(fixture_location)
    #  end
    #  it "can accept a fedora url as an argument and intialize a connection to fedora" do
    #    fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
    #    hfo = FtkProcessor.new(:fedora_config => fedora_config)
    #    Fedora::Repository.instance.fedora_version.should eql("3.4.2")
    #  end
  end
  
  # context "extract collection level values" do
  #   before(:all) do
  #     @report = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
  #     @r = FtkProcessor.new(:ftk_report => @report)
  #   end
  #   
  #   it "can extract the collection title" do
  #     @r.collection_title.should eql("Stephen Jay Gould papers")
  #   end
  #   
  #   it "can extract the collection call number" do
  #     @r.call_number.should eql("M1437")
  #   end
  #   
  #   it "can extract the series information" do
  #     @r.series.should eql("Series 6: Born Digital Materials")
  #   end
  # end
  
  # leave this section commented
  # context "process a single file" do
  #   before(:all) do
  #     snip = File.join(File.dirname(__FILE__), "/../fixtures/file_snip.xml")
  #     @doc = Nokogiri::XML(File.open(snip))
  #   end
  #   it "can process a single node" do
  #     fp = FtkProcessor.new()
  #     ff = fp.process_node(@doc.xpath("/fo:"))
  #     puts ff.inspect
  #   end
  # end
  
  # context "file description" do
  #   before(:all) do
  #     @report = File.join(File.dirname(__FILE__), "/../fixtures/Gould_FTK_Report.xml")
  #     @r = FtkProcessor.new(:ftk_report => @report)
  #   end
  #   
  #   it "knows how many files are represented" do
  #     @r.file_count.should eql(56)
  #   end
  #   
  #   it "has the file name of each file" do
  #     @r.files["NATHIN32_52007"].filename.should eql("NATHIN32")
  #     @r.files["NATHIN32_52007"].id.should eql("52007")
  #   end
  #   
  #       
  #    it "has the size of each file" do
  #      @r.files["NATHIN32_52007"].filesize.should eql("37180 B")
  #    end
  #    
  #    it "has the filetype of each file" do
  #      @r.files["NATHIN32_52007"].filetype.should eql("WordPerfect 5.1")
  #    end
  #    
  #    it "has the filepath of each file" do
  #      @r.files["NATHIN32_52007"].filepath.should eql("CM117.001/NONAME [FAT12]/[root]/NATHIN32")
  #    end
  #    
  #    it "has the disk image number of each file" do
  #      @r.files["NATHIN32_52007"].disk_image_number.should eql("CM117")
  #    end
  #    
  #    it "has the file creation date of each file" do
  #      @r.files["NATHIN32_52007"].file_creation_date.should eql("n/a")
  #      @r.files["gould_407_linages_10_characters.txt_30005"].file_creation_date.should eql("7/23/2010 2:47:38 PM (2010-07-23 21:47:38 UTC)")
  #    end
  #    
  #    it "has the file accessed date of each file" do
  #      @r.files["gould_407_linages_10_characters.txt_30005"].file_accessed_date.should eql("9/1/2010 1:43:58 PM (2010-09-01 20:43:58 UTC)")
  #    end
  #    
  #    it "has the file modified date of each file" do
  #      @r.files["gould_407_linages_10_characters.txt_30005"].file_modified_date.should eql("9/24/2008 5:52:37 AM (2008-09-24 12:52:37 UTC)")
  #    end
  #    
  #    it "has labels for each file" do      
  #      @r.files["gould_407_linages_10_characters.txt_30005"].access_rights.should eql("Public")
  #      @r.files["gould_407_linages_10_characters.txt_30005"].medium.should eql("Punch Cards")
  #      @r.files["BUR4-2_157003"].title.should eql("The Burgess Shale and the Nature of History")
  #      @r.files["BUR4-2_157003"].medium.should eql("5.25 inch Floppy Disks")
  #    end
  #    
  #    it "has an md5 hash for each file" do
  #      @r.files["BUR4-2_157003"].md5.should eql("4E1AA0E78D99191F4698EEC437569D23")
  #    end
  #    
  #    it "has an sha1 hash for each file" do
  #      @r.files["BUR4-2_157003"].sha1.should eql("B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C")
  #    end
  #    
  #    it "has the export path for each file" do
  #      @r.files["gould_407_linages_10_characters.txt_30005"].export_path.should eql("files/gould_407_linages_10_characters.txt")
  #    end
  #    
  #    it "knows whether this file is restricted" do
  #      @r.files["gould_407_linages_10_characters.txt_30005"].restricted.should eql("False")
  #    end
  #    
  #    it "knows whether this is a duplicate file" do
  #      @r.files["gould_407_linages_10_characters.txt_30005"].duplicate.should eql(" ")
  #      @r.files["SJG&amp;BR.W50_111004"].duplicate.should eql("M")
  #      @r.files["SJG&amp;BR.W50_118007"].duplicate.should eql("D")
  #      
  #    end
  #   
  # end
  
end