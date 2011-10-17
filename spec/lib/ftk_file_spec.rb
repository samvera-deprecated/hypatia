require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FtkFile do
  context "basic behavior" do
    before(:all) do
      @ff = FtkFile.new
    end
    it "can instantiate" do
      @ff.class.should eql(FtkFile)
    end
    it "responds to all of the fields a file object needs" do
      # @ff.send("#{key}=".to_sym, value)
      
      fields = [:filename=,:id=,:filesize=,:filetype=,:filepath=,:disk_image_number=,
          :file_creation_date=,:file_accessed_date=,:file_modified_date=,:medium=,:title=,
          :access_rights=,:duplicate=,:restricted=,:md5=,:sha1=,:export_path=,:unique_combo=,:type=]
      fields.each do |field|
        @ff.send(field,"foo").should eql("foo")
      end
    end
    it "updates the destination_file when export_path is set" do
      @ff.export_path = "/really/long/path/to/filename.txt"
      @ff.destination_file.should eql("filename.txt")
    end
    
    it "calculates a title when there isn't one" do
      ff = FtkFile.new
      ff.filename = "NATHIN40.WPD"
      # ff.type="Natural History Magazine Column"
      ff.title.should eql(ff.filename)
    end
    
    # If the filename is NATHIN50.WPD the display derivative name is NATHIN50.htm
    it "calculates the display derivative filename" do
      @ff.filename = "NATHIN40.WPD"
      @ff.display_deriv_fname.should eql("NATHIN40.htm")
    end
    
    it "calculates the mime type from the file extension" do
      @ff.filename = "foo.wpd"
      @ff.mimetype.should eql("application/vnd.wordperfect")
      @ff.filename = "foo.WPD"
      @ff.mimetype.should eql("application/vnd.wordperfect")
      @ff.filename = "foo"
      @ff.mimetype.should be_nil
    end
    
  end
end