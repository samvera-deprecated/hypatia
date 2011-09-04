require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")

describe FtkFile do
  context "basic behavior" do
    it "can instantiate" do
      hfo = FtkFile.new
      hfo.class.should eql(FtkFile)
    end
    it "responds to all of the fields a file object needs" do
      hfo = FtkFile.new
      # ff.send("#{key}=".to_sym, value)
      
      fields = [:filename=,:id=,:filesize=,:filetype=,:filepath=,:disk_image_number=,
          :file_creation_date=,:file_accessed_date=,:file_modified_date=,:medium=,:title=,
          :access_rights=,:duplicate=,:restricted=,:md5=,:sha1=,:export_path=,:unique_combo=,:type=]
      fields.each do |field|
        hfo.send(field,"foo").should eql("foo")
      end
    end
    it "updates the destination_file when export_path is set" do
      ff = FtkFile.new
      ff.export_path = "/really/long/path/to/filename.txt"
      ff.destination_file.should eql("filename.txt")
    end
  end
end