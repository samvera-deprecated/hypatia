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
    
    it "can accept an FTK XML report as input" do
         fixture_location = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
         r = FtkProcessor.new(:ftk_report => fixture_location)
         r.ftk_report.should eql(fixture_location)
       end
       # it "can accept a fedora url as an argument and intialize a connection to fedora" do
       #   fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
       #   hfo = FtkProcessor.new(:fedora_config => fedora_config)
       #   Fedora::Repository.instance.fedora_version.should eql("3.4.2")
       # end
  end
  
  context "extract collection level values" do
    before(:all) do
      @report = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
      @r = FtkProcessor.new(:ftk_report => @report)
    end
    
    it "can extract the collection title" do
      @r.collection_title.should eql("Stephen Jay Gould papers")
    end
    
    it "can extract the collection call number" do
      @r.call_number.should eql("M1437")
    end
    
    it "can extract the series information" do
      @r.series.should eql("Series 6: Born Digital Materials")
    end
  end
  
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
  
  context "file description" do
    before(:all) do
      @report = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
      @r = FtkProcessor.new(:ftk_report => @report)
    end
    
    it "knows how many files are represented" do
      @r.file_count.should eql(6)
    end
    
    it "has the file name of each file" do
      @r.files["BURCH3_3006"].filename.should eql("BURCH3")
      @r.files["BURCH3_3006"].id.should eql("3006")
    end
        
     it "has the size of each file" do
       @r.files["BURCH3_3006"].filesize.should eql("71835 B")
     end
     
     it "has the filetype of each file" do
       @r.files["BURCH3_3006"].filetype.should eql("WordPerfect 4.2")
     end
     
     it "has the filepath of each file" do
       @r.files["BURCH3_3006"].filepath.should eql("CM005.001/NONAME [FAT12]/[root]/BURCH3")
     end
     
     it "has the disk image number of each file" do
       @r.files["BURCH3_3006"].disk_image_number.should eql("CM005")
     end
     
     it "has the file creation date of each file" do
       @r.files["BURCH3_3006"].file_creation_date.should eql("n/a")
       @r.files["Description.txt_30002"].file_creation_date.should eql("7/23/2010 2:47:38 PM (2010-07-23 21:47:38 UTC)")
     end
     
     it "has the file accessed date of each file" do
       @r.files["Description.txt_30002"].file_accessed_date.should eql("9/1/2010 1:43:58 PM (2010-09-01 20:43:58 UTC)")
     end
     
     it "has the file modified date of each file" do
       @r.files["Description.txt_30002"].file_modified_date.should eql("1/14/2009 1:32:39 AM (2009-01-14 09:32:39 UTC)")
     end
     
     it "has labels for each file" do      
       @r.files["Description.txt_30002"].access_rights.should eql("Public")
       @r.files["Description.txt_30002"].medium.should eql("Punch Cards")
       @r.files["BU3A5_1004"].title.should eql("The Burgess Shale and the Nature of History")
       @r.files["BU3A5_1004"].medium.should eql("5.25 inch Floppy Disks")
     end
     
     it "has an md5 hash for each file" do
       @r.files["BU3A5_1004"].md5.should eql("976EDB782AE48FE0A84761BB608B1880")
     end
     
     it "has an sha1 hash for each file" do
       @r.files["BU3A5_1004"].sha1.should eql("E718AEFF97B5A5E6B4B2A7812CD87B64C150F3DF")
     end
     
     it "has the export path for each file" do
       @r.files["BU3A5_1004"].export_path.should eql("files/BU3A5")
     end
     
     it "knows whether this file is restricted" do
       @r.files["BU3A5_1004"].restricted.should eql("False")
     end
     
     it "knows whether this is a duplicate file" do
       @r.files["BU3A5_1004"].duplicate.should eql(" ")
       # @r.files["SJG&amp;BR.W50_111004"].duplicate.should eql("M")
       # @r.files["SJG&amp;BR.W50_118007"].duplicate.should eql("D")
       
     end
    
  end
  
end