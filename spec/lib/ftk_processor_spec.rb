require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FtkProcessor do
  
  before(:all) do
    relative_report_loc = "/../fixtures/ftk/Gould_FTK_Report.xml"
    @full_report_loc = File.join(File.dirname(__FILE__), relative_report_loc)
    @ftkp = FtkProcessor.new(:ftk_report =>@full_report_loc)
  end
  
  context "basic behavior" do
    it "can instantiate" do
      fp = FtkProcessor.new
      fp.class.should eql(FtkProcessor)
    end
    
    it "can accept an FTK XML report as input" do
      @ftkp.ftk_report.should eql(@full_report_loc)
    end
# it "can accept a fedora url as an argument and intialize a connection to fedora" do
#   fedora_config = File.join(File.dirname(__FILE__), "/../config/fedora.yml")
#   hfo = FtkProcessor.new(:fedora_config => fedora_config)
#   Fedora::Repository.instance.fedora_version.should eql("3.4.2")
# end
  end
  
  context "extract collection level values" do
    it "can extract the collection title" do
      @ftkp.collection_title.should eql("Stephen Jay Gould papers")
    end
    
    it "can extract the collection call number" do
      @ftkp.call_number.should eql("M1437")
    end
    
    it "can extract the series information" do
      @ftkp.series.should eql("Series 6: Born Digital Materials")
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
  
  context "FtkFile intermediate objects" do
    it "exist for each file described in the ftk report" do
      @ftkp.files.size.should eql(6)
      @ftkp.files.keys.include?("BURCH3_3006").should be_true
      @ftkp.files.keys.include?("Description.txt_30002").should be_true
      @ftkp.files.keys.include?("BUR3-1_3005").should be_true
      @ftkp.files.keys.include?("BU3A5_1004").should be_true
      @ftkp.files.keys.include?("BURCH1_3004").should be_true
      @ftkp.files.keys.include?("BURCH2_3003").should be_true
    end
    
    context "each FtkFile intermediate object" do
      it "has the correct file name" do
        @ftkp.files["BURCH3_3006"].filename.should eql("BURCH3")
        @ftkp.files["Description.txt_30002"].filename.should eql("Description.txt")
      end
        
      it "has the correct ftk identifier" do
        @ftkp.files["BURCH3_3006"].id.should eql("3006")
      end
        
      it "has the correct file size" do
        @ftkp.files["BURCH3_3006"].filesize.should eql("71835 B")
      end

      it "has the correct filetype" do
        @ftkp.files["BURCH3_3006"].filetype.should eql("WordPerfect 4.2")
      end

      it "has the correct filepath" do
        @ftkp.files["BURCH3_3006"].filepath.should eql("CM005.001/NONAME [FAT12]/[root]/BURCH3")
      end

      it "has the correct disk image number" do
        @ftkp.files["BURCH3_3006"].disk_image_number.should eql("CM005")
      end

      it "has the correct file creation date" do
        @ftkp.files["BURCH3_3006"].file_creation_date.should eql("n/a")
        @ftkp.files["Description.txt_30002"].file_creation_date.should eql("7/23/2010 2:47:38 PM (2010-07-23 21:47:38 UTC)")
      end

      it "has the correct file last accessed date" do
        @ftkp.files["Description.txt_30002"].file_accessed_date.should eql("9/1/2010 1:43:58 PM (2010-09-01 20:43:58 UTC)")
      end

      it "has the correct file last modified date" do
        @ftkp.files["Description.txt_30002"].file_modified_date.should eql("1/14/2009 1:32:39 AM (2009-01-14 09:32:39 UTC)")
      end

      it "has the correct access_right populated from labels" do      
        @ftkp.files["Description.txt_30002"].access_rights.should eql("Public")
      end

      it "has the correct medium populated from labels" do      
        @ftkp.files["Description.txt_30002"].medium.should eql("Punch Cards")
        @ftkp.files["BU3A5_1004"].medium.should eql("5.25 inch Floppy Disks")
      end

      it "has the correct title populated from labels" do      
        @ftkp.files["BU3A5_1004"].title.should eql("The Burgess Shale and the Nature of History")
      end

      it "has the correct md5 hash" do
        @ftkp.files["BU3A5_1004"].md5.should eql("976EDB782AE48FE0A84761BB608B1880")
      end

      it "has the correct sha1 hash" do
        @ftkp.files["BU3A5_1004"].sha1.should eql("E718AEFF97B5A5E6B4B2A7812CD87B64C150F3DF")
      end

      it "has the correct export path" do
        @ftkp.files["BU3A5_1004"].export_path.should eql("files/BU3A5")
      end

      it "has the correct restricted value" do
        @ftkp.files["BU3A5_1004"].restricted.should eql("False")
      end

      it "has the correct duplicate file value" do
        @ftkp.files["BU3A5_1004"].duplicate.should eql(" ")
       # @ftkp.files["SJG&amp;BR.W50_111004"].duplicate.should eql("M")
       # @ftkp.files["SJG&amp;BR.W50_118007"].duplicate.should eql("D")
      end

    end # context "each FtkFile intermediate object"
  end # context "FtkFile intermediate objects" 
end # FtkProcessor