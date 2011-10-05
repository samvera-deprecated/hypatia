require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_disk_image_item_assembler")

describe FtkDiskImageItemAssembler do
  context "basic behavior" do
    before(:all) do
      delete_fixture("hypatia:fixture_xanadu_collection")
      import_fixture("hypatia:fixture_xanadu_collection")
      @collection_pid = "hypatia:fixture_xanadu_collection"
      @disk_image_files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
      @computer_media_photos_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/computer_media_photos")
      @foo = FtkDiskImageItemAssembler.new(:collection_pid => @collection_pid, :disk_image_files_dir => @disk_image_files_dir, :computer_media_photos_dir => @computer_media_photos_dir)
    end
    after(:all) do
      delete_fixture("hypatia:fixture_xanadu_collection")
    end
    it "has a source of disk image files" do
      @foo.disk_image_files_dir.should eql(@disk_image_files_dir)
    end
    it "knows what collection the objects belong to" do
      @foo.collection_pid.should eql(@collection_pid)
    end
    it "has a source of computer media photos" do
      @foo.computer_media_photos_dir.should eql(@computer_media_photos_dir)
    end
    it "throws an error if you pass it an invalid disk image files directory" do
      dir = "fakedir"
      lambda{FtkDiskImageItemAssembler.new(:disk_image_files_dir => dir, :computer_media_photos_dir => @computer_media_photos_dir)}.should raise_exception
    end
    it "loads the files in the directory into a hash" do
      @foo.filehash.class.should eql(Hash)
      @foo.filehash[:CM5551212][:dd].should eql("#{@disk_image_files_dir}/CM5551212.001")
      @foo.filehash[:CM5551212][:csv].should eql("#{@disk_image_files_dir}/CM5551212.001.csv")
      @foo.filehash[:CM5551212][:txt].should eql("#{@disk_image_files_dir}/CM5551212.001.txt")
    end
  end
  
  context "extracting metadata" do
    before(:all) do
      @disk_image_files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
      @computer_media_photos_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/computer_media_photos")
      @txt_file = File.join(@disk_image_files_dir, "/CM5551212.001.txt")
      @assembler = FtkDiskImageItemAssembler.new(:disk_image_files_dir => @disk_image_files_dir, :computer_media_photos_dir => @computer_media_photos_dir)
      @fdi = FtkDiskImage.new(:txt_file => @txt_file)
    end
    it "creates an FtkDiskImage from a .txt file" do
      @fdi.md5.should eql("7d7abca99f383487e02ce7bf7c017267")
    end
    it "calculates the file size for the dd file referenced" do
      @assembler.calculate_dd_size(@fdi).should eql("368640 B")
    end
    it "creates descMetadata for an FtkDiskImage" do
      doc = Nokogiri::XML(@assembler.build_desc_metadata(@fdi))
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql(@fdi.disk_number)
      doc.xpath("/mods:mods/mods:physicalDescription/mods:extent/text()").to_s.should eql(@fdi.disk_type)
    end
    it "creates contentMetdata for an FtkDiskImage" do
      doc = Nokogiri::XML(@assembler.build_content_metadata(@fdi,"foo","bar"))
      doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
      doc.xpath("/contentMetadata/@objectId").to_s.should eql("foo")
      doc.xpath("/contentMetadata/resource/@type").to_s.should eql("disk-image")
      doc.xpath("/contentMetadata/resource/file/@id").to_s.should eql(@fdi.disk_number)
      doc.xpath("/contentMetadata/resource/file/@format").to_s.should eql("BINARY")
    end
  end
  
  context "building an object" do
    before(:all) do
      delete_fixture("hypatia:fixture_xanadu_collection")
      import_fixture("hypatia:fixture_xanadu_collection")
      @collection_pid = "hypatia:fixture_xanadu_collection"
      @disk_image_files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
      @computer_media_photos_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/computer_media_photos")
      @txt_file = File.join(@disk_image_files_dir, "/CM5551212.001.txt")
      @assembler = FtkDiskImageItemAssembler.new(:collection_pid => @collection_pid, :disk_image_files_dir => @disk_image_files_dir, :computer_media_photos_dir => @computer_media_photos_dir)
      @fdi = FtkDiskImage.new(:txt_file => @txt_file)  
      @item = @assembler.build_object(@fdi)
    end
    after(:all) do
      delete_fixture("hypatia:fixture_xanadu_collection")
      @item.parts.first.delete
      @item.delete
    end
    it "builds an object" do
      @item.should be_kind_of(HypatiaDiskImageItem)
    end
    it "the object has an isMemberOfCollection relationship with the collection object" do
      @item.relationships[:self][:is_member_of_collection].first.gsub("info:fedora/",'').should eql(@assembler.collection_pid)
    end
    it "the object has a FileAsset" do
      @item.parts.first.should be_kind_of(FileAsset)
    end
    it "has a binary disk image attached to the FileAsset" do
      fa = @item.parts.first
      fa.datastreams['content'].should_not eql(nil)
    end
    it "has an image attached to the FileAsset" do
      fa = @item.parts.first
      fa.datastreams['front'].should_not eql(nil)
    end
  end
end