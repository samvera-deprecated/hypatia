require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")

describe FtkDiskImage do
  context "basic behavior" do
    before(:all) do
      @txt_file = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images/CM5551212.001.txt")
      @fdi = FtkDiskImage.new(@txt_file)
    end
    it "can instantiate" do
      @fdi.class.should eql(FtkDiskImage)
    end
    it "sets the value of txt_file" do
      @fdi.txt_file.should eql(@txt_file)
    end
    it "extracts the disk name" do
      @fdi.disk_name.should eql("CM5551212")
    end
    it "extracts the case number" do
      @fdi.case_number.should eql("M1437")
    end
    it "extracts the media type" do
      @fdi.disk_type.should eql("5.25 inch Floppy Disk")
    end
    it "extracts the md5 checksum" do
      @fdi.md5.should eql("7d7abca99f383487e02ce7bf7c017267")
    end
    it "extracts the sha1 checksum" do
      @fdi.sha1.should eql("628ede981ad24c1655f7e37057355ca689dcb3a9")
    end
  end
end