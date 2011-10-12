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
      f.display_derivative.should eql("NATHIN40.htm")
    end
    
    it "calculates the mime type from the file extension" do
      f = FtkFile.new
      f.filename = "foo.wpd"
      f.mimetype.should eql("application/vnd.wordperfect")
      f.filename = "foo.WPD"
      f.mimetype.should eql("application/vnd.wordperfect")
    end

    it "calculates the mimetype from the file itself when there is no file extension" do
      f = FtkFile.new
      f.export_path = "../Rakefile"
      f.filename = "Rakefile"
      f.mimetype.should eql("text/plain")
      f.export_path = "../spec/fixtures/ftk/files/BURCH1"
      f.filename = "BURCH1"
      f.mimetype.should eql("application/octet-stream")
      # unrecognized extension
      f.export_path = "../README.textile"
      f.filename = "README.textile"
      f.mimetype.should eql("text/plain")
    end
    
  end
end