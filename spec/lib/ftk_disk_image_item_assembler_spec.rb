require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_disk_image_item_assembler")

describe FtkDiskImageItemAssembler do
  context "basic behavior" do
    before(:all) do
      @files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
    end
    it "has a source of disk image files" do
      foo = FtkDiskImageItemAssembler.new(:disk_image_files_dir => @files_dir)
      foo.disk_image_files_dir.should eql(@files_dir)
    end
    it "throws an error if you pass it an invalid directory" do
      dir = "fakedir"
      lambda{FtkDiskImageItemAssembler.new(:disk_image_files_dir => dir)}.should raise_exception
    end
    it "loads the files in the directory into a hash" do
      foo = FtkDiskImageItemAssembler.new(:disk_image_files_dir => @files_dir)
      foo.filehash.class.should eql(Hash)
      foo.filehash[:CM006][:dd].should eql("#{@files_dir}/CM006.001")
      foo.filehash[:CM006][:csv].should eql("#{@files_dir}/CM006.001.csv")
      foo.filehash[:CM006][:txt].should eql("#{@files_dir}/CM006.001.txt")
    end
  end
  context "extracting metadata" do
    before(:all) do
      @files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
      @txt_file = File.join(@files_dir, "/CM006.001.txt")
      @assembler = FtkDiskImageItemAssembler.new(:disk_image_files_dir => @files_dir)
      @fdi = FtkDiskImage.new(:txt_file => @txt_file)
      
    end
    it "creates an FtkDiskImage from a .txt file" do
      @fdi.md5.should eql("7d7abca99f383487e02ce7bf7c017267")
    end
    it "calculates the file size for the dd file referenced" do
      @assembler.calculate_dd_size(@fdi).should eql("368640 B")
    end
    it "creates descMetadata for an FtkDiskImage" do
      doc = Nokogiri::XML(@assembler.buildDescMetadata(@fdi))
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql(@fdi.disk_number)
      doc.xpath("/mods:mods/mods:physicalDescription/mods:extent/text()").to_s.should eql(@fdi.disk_type)
    end
    it "creates contentMetdata for an FtkDiskImage" do
      doc = Nokogiri::XML(@assembler.buildContentMetadata(@fdi,"foo","bar"))
      doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
      doc.xpath("/contentMetadata/@objectId").to_s.should eql("foo")
      doc.xpath("/contentMetadata/resource/@type").to_s.should eql("disk-image")
      doc.xpath("/contentMetadata/resource/file/@id").to_s.should eql(@fdi.disk_number)
      doc.xpath("/contentMetadata/resource/file/@format").to_s.should eql("BINARY")
    end
  end
  context "building an object" do
    before(:all) do
      @files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
      @txt_file = File.join(@files_dir, "/CM006.001.txt")
      @assembler = FtkDiskImageItemAssembler.new(:disk_image_files_dir => @files_dir)
      @fdi = FtkDiskImage.new(:txt_file => @txt_file)  
      @item = @assembler.build_object(@fdi)
    end
    it "builds an object" do
      @item.should be_kind_of(HypatiaDiskImageItem)
    end
  end
end