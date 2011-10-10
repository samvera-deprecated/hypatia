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
    it "creates and populates an FtkDiskImage object from a .txt file" do
      # see ftk_disk_image_spec for more 
      @fdi.txt_file.should match(/.*\/fixtures\/ftk\/disk_images\/CM5551212\.001\.txt$/)
      @fdi.disk_number.should eql("CM5551212")
      @fdi.disk_type.should eql("5.25 inch Floppy Disk")
      @fdi.md5.should eql("7d7abca99f383487e02ce7bf7c017267")
      @fdi.sha1.should eql("628ede981ad24c1655f7e37057355ca689dcb3a9")
    end
    it "calculates the file size for the dd file referenced" do
      @assembler.calculate_dd_size(@fdi).should eql("368640 B")
    end
    it "creates descMetadata for an FtkDiskImage" do
      doc = Nokogiri::XML(@assembler.build_desc_metadata(@fdi))
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql(@fdi.disk_number)
      doc.xpath("/mods:mods/mods:physicalDescription/mods:extent/text()").to_s.should eql(@fdi.disk_type)
    end
=begin   superceded
    it "creates contentMetdata for an FtkDiskImage" do
      doc = Nokogiri::XML(@assembler.build_content_metadata(@fdi,"foo","bar"))
      doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
      doc.xpath("/contentMetadata/@objectId").to_s.should eql("foo")
      doc.xpath("/contentMetadata/resource/@type").to_s.should eql("disk-image")
      doc.xpath("/contentMetadata/resource/file/@id").to_s.should eql(@fdi.disk_number)
      doc.xpath("/contentMetadata/resource/file/@format").to_s.should eql("BINARY")
    end
=end
  end
  
  context "FileAssets and their contentMetadata in the DiskImageItem" do
    before(:all) do
      @collection_pid = "hypatia:fixture_coll2" # also used below
      delete_fixture(@collection_pid)
      import_fixture(@collection_pid)
      @disk_image_files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
      @computer_media_photos_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/computer_media_photos")
      @txt_file = File.join(@disk_image_files_dir, "/CM5551212.001.txt")
      @assembler = FtkDiskImageItemAssembler.new(:collection_pid => @collection_pid, :disk_image_files_dir => @disk_image_files_dir, :computer_media_photos_dir => @computer_media_photos_dir)
      @disk_image_item = HypatiaDiskImageItem.new
      @disk_image_full_pid = @disk_image_item.internal_uri
      @fdi = FtkDiskImage.new(:txt_file => @txt_file)
      @dd_file_asset = @assembler.create_dd_file_asset(@disk_image_item, @fdi)
      dd_file_ds_name = @dd_file_asset.datastreams.keys.select {|k| k !~ /(DC|RELS\-EXT|descMetadata)/}.first
      @dd_file_ds = @dd_file_asset.datastreams[dd_file_ds_name]
      @photo_file_asset_array = @assembler.create_photo_file_assets(@disk_image_item, @fdi)
    end
    context "with FTK .txt file" do
      it "creates the correct FileAsset object for disk image itself" do
        @dd_file_asset.should be_instance_of(FileAsset) # model
        @dd_file_asset.relationships[:self][:is_part_of].should == ["#{@disk_image_full_pid}"]

        # DC, RELS-EXT, descMetadata, (the datastream the file is stored in)
        @dd_file_asset.datastreams.size.should == 4

        # file datastream:
        @dd_file_ds[:dsLabel].should == "CM5551212" # from Evidence Number : line of FTK .txt file -- the file name
        @dd_file_ds[:mimeType].should == "application/octet-stream"
        
        # descMetadata:
        desc_md_ds_fields_hash = @dd_file_asset.datastreams["descMetadata"].fields
        prefix = "FileAsset for FTK disk image " # constant
        phys_desc = "5.25 inch Floppy Disk "  # from Notes:  line of FTK .txt file
        disk_num = "CM5551212"  # from Evidence Number:  line of FTK .txt file
        desc_md_ds_fields_hash[:title][:values].should == ["#{prefix}#{phys_desc}#{disk_num}"]
        # extent value (file size) is computed by FileAsset.add_file_datastream
        desc_md_ds_fields_hash[:extent][:values].first.should match(/(bytes|KB|MB|GB|TB)$/)
      end

      it "creates the correct FileAsset objects for the photos of the disk" do
        @photo_file_asset_array.size.should == 3  # we have 3 matching fixture images: plain, _1, and _2
        
        @photo_file_asset_array.each { | file_asset |  
          file_asset.should be_instance_of(FileAsset) # model
          file_asset.relationships[:self][:is_part_of].should == ["#{@disk_image_full_pid}"]

          # DC, RELS-EXT, descMetadata, (the datastream the file is stored in)
          file_asset.datastreams.size.should == 4

          # datastream containing the photo file
          file_ds_name = file_asset.datastreams.keys.select {|k| k !~ /(DC|RELS\-EXT|descMetadata)/}.first
          file_ds = file_asset.datastreams[file_ds_name]
          file_ds[:dsLabel].should match(/^CM5551212(_1|_2)?\.JPG$/)  # the file name of the image (xxx.jpeg, whatever)
          file_ds.mime_type.should == "image/jpeg"

          # descMetadata:
          desc_md_ds_fields_hash = file_asset.datastreams["descMetadata"].fields
          prefix = "FileAsset for photo of FTK disk image " # constant
          disk_num = "CM5551212"  # from Evidence Number:  line of FTK .txt file
          desc_md_ds_fields_hash[:title][:values].should == ["#{prefix}#{disk_num}"]
          # extent value (file size) is computed by FileAsset.add_file_datastream
          desc_md_ds_fields_hash[:extent][:values].first.should match(/(bytes|KB|MB|GB|TB)$/)
        }
      end
      
      context "contentMetadata" do
        before(:all) do
          @doc_one_image = Nokogiri::XML(@assembler.build_content_metadata(@fdi, "dii_pid", @dd_file_asset, @photo_file_asset_array[0..0]))
          @doc_two_images = Nokogiri::XML(@assembler.build_content_metadata(@fdi, "dii_pid", @dd_file_asset, @photo_file_asset_array[1..2]))
        end
        
#        it "creates contentMetadata datastream that adheres to HypatiaDiskImageContentMetadataDS model" do
#          pending
#        end
        it "creates the correct contentMetdata element" do
          @doc_one_image.xpath("/contentMetadata/@objectId").to_s.should eql("dii_pid")
          @doc_one_image.xpath("/contentMetadata/@type").to_s.should eql("file")
        end
        it "creates the correct resource element for the disk image FileAsset" do
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/@objectId").to_s.should eql(@dd_file_asset.pid)
          # id attribute on resource element is just a unique identifier
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/@id").to_s.should eql(@dd_file_ds[:dsLabel])
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/@id").to_s.should eql("CM5551212")
          # id attribute on file element must match the label of the datastream in the FileAsset object
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@id").to_s.should eql(@dd_file_ds[:dsLabel])
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@id").to_s.should eql("CM5551212")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@format").to_s.should eql("BINARY")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@mimetype").to_s.should eql("application/octet-stream")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@size").to_s.should match(/^\d+$/)
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@preserve").to_s.should eql("yes")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@publish").to_s.should eql("yes")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/@shelve").to_s.should eql("yes")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/location/@type").to_s.should eql("datastreamID")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/location/text()").to_s.should eql(@dd_file_ds.dsid)
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/checksum[@type='md5']/text()").to_s.should eql("7d7abca99f383487e02ce7bf7c017267")
          @doc_one_image.xpath("/contentMetadata/resource[@type='media-file']/file/checksum[@type='sha1']/text()").to_s.should eql("628ede981ad24c1655f7e37057355ca689dcb3a9")
        end
        it "creates the correct resource element for a single photo image FileAsset" do
          image_file_asset = @photo_file_asset_array[0]
          ds_name = image_file_asset.datastreams.keys.select {|k| k !~ /(DC|RELS\-EXT|descMetadata)/}.first
          image_ds = image_file_asset.datastreams[ds_name]
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/@objectId").to_s.should eql(image_file_asset.pid)
          # id attribute on resource element is just a unique identifier
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/@id").to_s.should eql(image_ds[:dsLabel])
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/@id").to_s.should eql("CM5551212.JPG")
          # id attribute on file element must match the label of the datastream in the FileAsset object
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@id").to_s.should eql(image_ds[:dsLabel])
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@id").to_s.should eql("CM5551212.JPG")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@format").to_s.should eql("JPG")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@mimetype").to_s.should eql("image/jpeg")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@size").to_s.should match(/^\d+$/)
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@preserve").to_s.should eql("yes")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@publish").to_s.should eql("yes")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/@shelve").to_s.should eql("yes")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/location/@type").to_s.should eql("datastreamID")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/location/text()").to_s.should eql(image_ds.dsid)
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/checksum[@type='md5']/text()").to_s.should eql("812b53258f21ee250d17c9308d2099d9")
          @doc_one_image.xpath("/contentMetadata/resource[@type='image-front']/file/checksum[@type='sha1']/text()").to_s.should eql("da39a3ee5e6b4b0d3255bfef95601890afd80709")
        end
#        it "creates the correct resource elements for two photo image FileAsset objects" do
#          pending
#        end

        
      end # context contentMetadata

  end # context "FileAssets and their contentMetadata in the DiskImageItem"
  
  
  
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
      fa.datastreams['DS1'].should_not eql(nil)
    end
# FIXME:  no, it will have its own file asset object    
#    it "has an image attached to the FileAsset" do
#      fa = @item.parts.first
#      fa.datastreams['front'].should_not eql(nil)
    end
  end
end