require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
    
    it "calculates a title when there isn't one" do
      f = FtkFile.new
      f.filename = "NATHIN40.WPD"
      # f.type="Natural History Magazine Column"
      f.title.should eql(f.filename)
    end
    
    # If the filename is NATHIN50.WPD the display derivative name is NATHIN50.htm
    it "calculates the display derivative filename" do
      f = FtkFile.new
      f.filename = "NATHIN40.WPD"
      f.display_deriv_fname.should eql("NATHIN40.htm")
    end
    
    it "calculates the mime type from the file extension" do
      f = FtkFile.new
      f.filename = "foo.wpd"
      f.mimetype.should eql("application/vnd.wordperfect")
      f.filename = "foo.WPD"
      f.mimetype.should eql("application/vnd.wordperfect")
      f.filename = "foo"
      f.mimetype.should be_nil
    end
    
  end
end