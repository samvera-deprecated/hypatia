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
  
  context "FtkFile intermediate objects" do
    it "are in an array" do
      @ftkp.files.should be_an_instance_of(Array)
    end
    it "exist for each file described in the ftk report" do
      @ftkp.files.size.should eql(6)
    end
    
    context "each FtkFile intermediate object" do
      before(:all) do
        @burch3_ftkfile = @ftkp.files.detect { |file| file.filename == "BURCH3" && file.id == "3006"  }
        @desc_txt_ftkfile = @ftkp.files.detect { |file| file.filename == "Description.txt" && file.id == "30002"  }
        @bur3_1_ftkfile = @ftkp.files.detect { |file| file.filename == "BUR3-1" && file.id == "3005"  }
        @bu3a5_ftkfile = @ftkp.files.detect { |file| file.filename == "BU3A5" && file.id == "1004"  }
        @burch1_ftkfile = @ftkp.files.detect { |file| file.filename == "BURCH1" && file.id == "3004"  }
        @burch2_ftkfile = @ftkp.files.detect { |file| file.filename == "BURCH2" && file.id == "3003"  }
      end
      
      it "has the correct file name" do
        @burch3_ftkfile.filename.should eql("BURCH3")
        @desc_txt_ftkfile.filename.should eql("Description.txt")
      end
        
      it "has the correct ftk identifier" do
        @burch3_ftkfile.id.should eql("3006")
      end
        
      it "has the correct file size" do
        @burch3_ftkfile.filesize.should eql("71835 B")
      end

      it "has the correct filetype" do
        @burch3_ftkfile.filetype.should eql("WordPerfect 4.2")
      end

      it "has the correct filepath" do
        @burch3_ftkfile.filepath.should eql("CM005.001/NONAME [FAT12]/[root]/BURCH3")
      end

      it "has the correct disk image name" do
        @burch3_ftkfile.disk_image_name.should eql("CM005")
      end

      it "has the correct file creation date" do
        @burch3_ftkfile.file_creation_date.should eql("n/a")
        @desc_txt_ftkfile.file_creation_date.should eql("7/23/2010 2:47:38 PM (2010-07-23 21:47:38 UTC)")
      end

      it "has the correct file last accessed date" do
        @desc_txt_ftkfile.file_accessed_date.should eql("9/1/2010 1:43:58 PM (2010-09-01 20:43:58 UTC)")
      end

      it "has the correct file last modified date" do
        @desc_txt_ftkfile.file_modified_date.should eql("1/14/2009 1:32:39 AM (2009-01-14 09:32:39 UTC)")
      end

      it "has the correct access_right populated from labels" do      
        @desc_txt_ftkfile.access_rights.should eql("Public")
      end

      it "has the correct medium populated from labels" do      
        @desc_txt_ftkfile.medium.should eql("Punch Cards")
        @bu3a5_ftkfile.medium.should eql("5.25 inch Floppy Disks")
      end

      it "has the correct title populated from labels" do      
        @bu3a5_ftkfile.title.should eql("The Burgess Shale and the Nature of History")
      end

      it "has the correct md5 hash" do
        @bu3a5_ftkfile.md5.should eql("976EDB782AE48FE0A84761BB608B1880")
      end

      it "has the correct sha1 hash" do
        @bu3a5_ftkfile.sha1.should eql("E718AEFF97B5A5E6B4B2A7812CD87B64C150F3DF")
      end

      it "has the correct export path" do
        @bu3a5_ftkfile.export_path.should eql("files/BU3A5")
      end

      it "has the correct restricted value" do
        @bu3a5_ftkfile.restricted.should eql("False")
      end

      it "has the correct duplicate file value" do
        @bu3a5_ftkfile.duplicate.should eql(" ")
        # actual values for duplicate would be "M" or "D" ...
       # @ftkp.files["SJG&amp;BR.W50_111004"].duplicate.should eql("M")
       # @ftkp.files["SJG&amp;BR.W50_118007"].duplicate.should eql("D")
      end

    end # context "each FtkFile intermediate object"
  end # context "FtkFile intermediate objects" 
end # FtkProcessor