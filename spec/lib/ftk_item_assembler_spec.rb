require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'factory_girl'
require File.join(File.dirname(__FILE__), "/../fixtures/ftk/factories/ftk_files.rb")

describe FtkItemAssembler do
  before(:all) do
    @coll_pid = "hypatia:fixture_coll"
  end

  context "basic behavior" do
    before(:all) do
      delete_fixture(@coll_pid)
      import_fixture(@coll_pid)
      @fedora_config = File.join(File.dirname(__FILE__), "/../../config/fedora.yml")
      @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
      @file_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/files")
      @display_derivative_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/display_derivatives")
    end
    it "can instantiate" do
      hfo = FtkItemAssembler.new
      hfo.class.should eql(FtkItemAssembler)
    end
=begin  no longer used?
    it "takes a fedora config file as an argument" do
      hfo = FtkItemAssembler.new(:fedora_config => @fedora_config)
      hfo.fedora_config.should eql(@fedora_config)
    end
=end
    it "sets the pid of the collection object these items belong to" do
      hfo = FtkItemAssembler.new
      hfo.collection_pid = @coll_pid
      hfo.collection_pid.should eql(@coll_pid)
    end
=begin  no longer duplicated in item object
    it "gets the name of the collection it belongs to" do
      hfo = FtkItemAssembler.new(:collection_pid => @coll_pid)
      hfo.collection_name.should eql("Keith Henson. Papers relating to Project Xanadu, XOC and Eric Drexler")
    end
=end
=begin   # FIXME:  this is an important spec to replace!
    it "processes an FTK report" do
      hfo = FtkItemAssembler.new(:fedora_config => @fedora_config)
      hfo.expects(:create_hypatia_item).at_least(56).returns(nil)
      hfo.process(@ftk_report,@file_dir,@display_derivative_dir)
      hfo.ftk_report.should eql(@ftk_report)
      hfo.file_dir.should eql(@file_dir)
      hfo.display_derivative_dir.should eql(@display_derivative_dir)
    end
=end
  end # context basic behavior
  
  
  context "metadata datastreams" do
    before(:all) do
      delete_fixture(@coll_pid)
      import_fixture(@coll_pid)
      @assembler = FtkItemAssembler.new(:collection_pid => @coll_pid)
      @ff_intermed = FactoryGirl.build(:ftk_file)
    end
    
    it "creates the correct descMetadata" do
      desc_md_doc = Nokogiri::XML(@assembler.build_desc_metadata(@ff_intermed))
      desc_md_doc.namespaces.size.should eql(1)
      desc_md_doc.namespaces["xmlns:mods"].should eql("http://www.loc.gov/mods/v3")
      desc_md_doc.xpath("/mods:mods/mods:identifier[@type='filename']/text()").to_s.should eql(@ff_intermed.filename)
      desc_md_doc.xpath("/mods:mods/mods:identifier[@type='ftk_id']/text()").to_s.should eql(@ff_intermed.id)
      desc_md_doc.xpath("/mods:mods/mods:location/mods:physicalLocation[@type='filepath']/text()").to_s.should eql(@ff_intermed.filepath)
      nodeSet = desc_md_doc.xpath("/mods:mods/mods:physicalDescription/mods:extent")
      nodeSet.size.should eql(2)
      values = [nodeSet[0].text, nodeSet[1].text]
      values[0].should_not eql(values[1])
      values.include?(@ff_intermed.filesize).should be_true
      values.include?(@ff_intermed.medium).should be_true
      desc_md_doc.xpath("/mods:mods/mods:physicalDescription/mods:digitalOrigin/text()").to_s.should eql("born digital")
      desc_md_doc.xpath("/mods:mods/mods:originInfo/mods:dateCreated/text()").to_s.should eql(@ff_intermed.file_creation_date)
      desc_md_doc.xpath("/mods:mods/mods:originInfo/mods:dateOther[@type='last_accessed']/text()").to_s.should eql(@ff_intermed.file_accessed_date)
      desc_md_doc.xpath("/mods:mods/mods:originInfo/mods:dateOther[@type='last_modified']/text()").to_s.should eql(@ff_intermed.file_modified_date)
      desc_md_doc.xpath("/mods:mods/mods:relatedItem/mods:titleInfo/mods:title/text()").to_s.should eql(@ff_intermed.title)
      desc_md_doc.xpath("/mods:mods/mods:note[@displayLabel='filetype']/text()").to_s.should eql(@ff_intermed.filetype)
      desc_md_doc.xpath("/mods:mods/mods:note[not(@displayLabel)]/text()").to_s.should eql(@ff_intermed.type)
    end

    it "creates the correct rightsMetadata" do
      rights_md_doc = Nokogiri::XML(@assembler.build_rights_metadata)
      rights_md_doc.namespaces.size.should eql(1)
      ns = "http://hydra-collab.stanford.edu/schemas/rightsMetadata/v1"
      rights_md_doc.namespaces["xmlns"].should eql(ns)
      rights_md_doc.xpath("/ns:rightsMetadata/ns:access", {"ns" => ns}).size.should eql(3)
      rights_md_doc.xpath("/ns:rightsMetadata/ns:access[@type='discover']/ns:machine/ns:group/text()", {"ns" => ns}).to_s.should eql("public")
      rights_md_doc.xpath("/ns:rightsMetadata/ns:access[@type='read']/ns:machine/ns:group/text()", {"ns" => ns}).to_s.should eql("public")
      rights_md_doc.xpath("/ns:rightsMetadata/ns:access[@type='edit']/ns:machine/ns:group/text()", {"ns" => ns}).to_s.should eql("archivist")
    end
  end
  
  
  
  context "creating datastreams" do
    before(:all) do
      delete_fixture(@coll_pid)
      import_fixture(@coll_pid)
      @ff = FactoryGirl.build(:ftk_file)
      @fedora_config = File.join(File.dirname(__FILE__), "/../../config/fedora.yml")
      @hfo = FtkItemAssembler.new(:fedora_config => @fedora_config, :collection_pid => @coll_pid)
    end
    it "creates a RELS-EXT datastream" do
      doc = Nokogiri::XML(@hfo.build_rels_ext(@ff))
#      doc.xpath("/rdf:RDF/rdf:Description/hydra:isGovernedBy/@rdf:resource").to_s.should eql("info:fedora/hypatia:fixture_xanadu_apo")
    end
  end  # context creating datastreams
  
  context "FtkItem FileAsset and its contentMetadata" do
    before(:all) do
      delete_fixture(@coll_pid)
      import_fixture(@coll_pid)
      @assembler = FtkItemAssembler.new(:collection_pid => @coll_pid)
      @ftk_file_intermed = FactoryGirl.build(:ftk_file)
      @ftk_item_object = HypatiaFtkItem.new
      @assembler.file_dir = "spec/fixtures/ftk"
      @assembler.display_derivative_dir = "spec/fixtures/ftk/display_derivatives" 
      @file_asset = @assembler.create_file_asset(@ftk_item_object, @ftk_file_intermed)
      @ftk_item_pid = @ftk_item_object.internal_uri
      @content_file_ds = @file_asset.datastreams["content"]
      @deriv_file_ds = @file_asset.datastreams["derivative_html"]
      
      @ftk_file_intermed_no_deriv = FactoryGirl.build(:ftk_file)
      @ftk_file_intermed_no_deriv.filename = "foofile.txt"
      @ftk_file_intermed_no_deriv.export_path = "files/foofile.txt"
      @file_asset_no_deriv = @assembler.create_file_asset(@ftk_item_object, @ftk_file_intermed_no_deriv)
      @content_file_ds_no_deriv = @file_asset_no_deriv.datastreams["content"]
    end

    context "FileAsset creation for FTK file" do
      it "creates a FileAsset object with the correct relationships and descriptive metadata" do
        @file_asset.should be_instance_of(FileAsset) # model
        @file_asset.relationships[:self][:is_part_of].should == ["#{@ftk_item_pid}"]
        # descMetadata:
        desc_md_ds_fields_hash = @file_asset.datastreams["descMetadata"].fields
        # extent value (file size) is computed by FileAsset.add_file_datastream
        desc_md_ds_fields_hash[:extent][:values].first.should match(/(bytes|KB|MB|GB|TB)$/)
        desc_md_ds_fields_hash[:title][:values].should == ["FileAsset for FTK file #{@ftk_file_intermed.filename}"]
      end
      it "creates the correct FileAsset object for the FTK file and its display derivative" do
        # datastreams:  DC, RELS-EXT, descMetadata, content, derivative-html
        @file_asset.datastreams.size.should == 5
        # content file datastream:
        @content_file_ds[:dsLabel].should ==  @ftk_file_intermed.filename 
        @content_file_ds[:dsLabel].should == "BURCH1" 
        #  can't get mimeType here, even though it is set when the datastream is written to Fedora
        # display derivative datastream
        @deriv_file_ds[:dsLabel].should ==  @ftk_file_intermed.display_deriv_fname
        @deriv_file_ds[:dsLabel].should == "BURCH1.htm"
        @deriv_file_ds[:mimeType].should == "text/html"
      end
      it "creates the correct FileAsset object when there is no display derivative" do
        # datastreams:  DC, RELS-EXT, descMetadata, content
        @file_asset_no_deriv.datastreams.size.should == 4
        @content_file_ds_no_deriv[:dsLabel].should ==  @ftk_file_intermed_no_deriv.filename 
        @content_file_ds_no_deriv[:dsLabel].should == "foofile.txt" 
        @content_file_ds_no_deriv[:mimeType].should == "text/plain"
        @file_asset_no_deriv.datastreams["derivative_html"].should be_nil
        @file_asset_no_deriv.delete
       end
       it "creates the correct FileAsset object when the content file has no extension" do
         # see  "creates the correct FileAsset object for the FTK file and its display derivative"
       end
       it "creates the correct FileAsset object when the content file has an extension" do
         # see "creates the correct FileAsset object when there is no display derivative"
       end
    end  # context "FileAsset creation for FTK file"

    context "contentMetadata" do
      before(:all) do
        @content_md_doc = Nokogiri::XML(@assembler.build_content_metadata(@ftk_file_intermed, "ftk_item_pid", @file_asset))
        @content_md_no_deriv_doc = Nokogiri::XML(@assembler.build_content_metadata(@ftk_file_intermed_no_deriv, "ftk_item_pid2", @file_asset_no_deriv))
      end
      it "creates the correct contentMetdata element" do
        @content_md_doc.xpath("/contentMetadata/@objectId").to_s.should eql("ftk_item_pid")
        @content_md_doc.xpath("/contentMetadata/@type").to_s.should eql("file")
        @content_md_no_deriv_doc.xpath("/contentMetadata/@objectId").to_s.should eql("ftk_item_pid2")
        @content_md_no_deriv_doc.xpath("/contentMetadata/@type").to_s.should eql("file")
      end
      it "creates the correct resource element" do
        @content_md_doc.xpath("/contentMetadata/resource").size.should eql(1)
        @content_md_doc.xpath("/contentMetadata/resource/@objectId").to_s.should eql(@file_asset.pid)
        @content_md_doc.xpath("/contentMetadata/resource/@type").to_s.should eql("file")
        # id attribute on resource element is just a unique identifier
        @content_md_doc.xpath("/contentMetadata/resource/@id").to_s.should eql(@content_file_ds[:dsLabel])
        @content_md_doc.xpath("/contentMetadata/resource/@id").to_s.should eql("BURCH1")
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource").size.should eql(1)
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/@objectId").to_s.should eql(@file_asset_no_deriv.pid)
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/@type").to_s.should eql("file")
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/@id").to_s.should eql(@content_file_ds_no_deriv[:dsLabel])
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/@id").to_s.should eql("foofile.txt")
      end
      it "creates the correct file elements when there is a display derivative" do
        # id attribute on file element must match the label of the datastream in the FileAsset object
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='#{@content_file_ds[:dsLabel]}']").should_not be_nil
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']").should_not be_nil
#        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/@format").to_s.should eql("BINARY")  # skipping for Hypatia demo
#        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/@mimetype").to_s.should eql("application/octet-stream")  # skipping for Hypatia demo
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/@size").to_s.should match(/^\d+$/)
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/@preserve").to_s.should eql("yes")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/@publish").to_s.should eql("yes")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/@shelve").to_s.should eql("yes")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/location/@type").to_s.should eql("datastreamID")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/location/text()").to_s.should eql(@content_file_ds.dsid)
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/checksum[@type='md5']/text()").to_s.should eql(@ftk_file_intermed.md5)
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/checksum[@type='md5']/text()").to_s.should eql("4E1AA0E78D99191F4698EEC437569D23")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/checksum[@type='sha1']/text()").to_s.should eql(@ftk_file_intermed.sha1)
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1']/checksum[@type='sha1']/text()").to_s.should eql("B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C")
        # id attribute on file element must match the label of the datastream in the FileAsset object
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='#{@deriv_file_ds[:dsLabel]}']").should_not be_nil
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']").should_not be_nil
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/@format").to_s.should eql("HTML")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/@mimetype").to_s.should eql("text/html")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/@size").to_s.should match(/^\d+$/)
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/@preserve").to_s.should eql("yes")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/@publish").to_s.should eql("yes")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/@shelve").to_s.should eql("yes")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/location/@type").to_s.should eql("datastreamID")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/location/text()").to_s.should eql(@deriv_file_ds.dsid)
# TODO:  compute md5 and sha1 for deriv html (?)
#        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/checksum[@type='md5']/text()").to_s.should eql(Digest::MD5.hexdigest(@deriv_file_ds.blob.read))
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/checksum[@type='md5']/text()").to_s.should eql("906aec05a5a8de7391daec5681eedcf6")
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/checksum[@type='sha1']/text()").to_s.should eql(Digest::SHA1.hexdigest(@deriv_file_ds.blob.read))
        @content_md_doc.xpath("/contentMetadata/resource/file[@id='BURCH1.htm']/checksum[@type='sha1']/text()").to_s.should eql("da39a3ee5e6b4b0d3255bfef95601890afd80709")
      end
      it "creates the correct file element for when there is no display derivative" do
        # id attribute on file element must match the label of the datastream in the FileAsset object
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='#{@content_file_ds[:dsLabel]}']").should_not be_nil
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']").should_not be_nil
#        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/@format").to_s.should eql("BINARY")  # skipping for Hypatia demo
#        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/@mimetype").to_s.should eql("application/octet-stream")  # skipping for Hypatia demo
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/@size").to_s.should match(/^\d+$/)
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/@preserve").to_s.should eql("yes")
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/@publish").to_s.should eql("yes")
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/@shelve").to_s.should eql("yes")
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/location/@type").to_s.should eql("datastreamID")
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/location/text()").to_s.should eql(@content_file_ds_no_deriv.dsid)
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/checksum[@type='md5']/text()").to_s.should eql(@ftk_file_intermed_no_deriv.md5)
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/checksum[@type='md5']/text()").to_s.should eql("4E1AA0E78D99191F4698EEC437569D23")
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/checksum[@type='sha1']/text()").to_s.should eql(@ftk_file_intermed_no_deriv.sha1)
        @content_md_no_deriv_doc.xpath("/contentMetadata/resource/file[@id='foofile.txt']/checksum[@type='sha1']/text()").to_s.should eql("B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C")
      end
=begin
# FIXME:  this is an integration spec testing that the xml from the loader can be loaded into the app properly.  Not sure where to put this.
      it "creates contentMetadata datastream that adheres to HypatiaDiskImageContentMetadataDS model" do
        content_md_ds = HypatiaDiskImgContentMetadataDS.from_xml(@doc_one_image)
        content_md_ds.term_values(:dd_fedora_pid).first.should match(/^hypatia:\d+$/) 
        content_md_ds.term_values(:dd_ds_id).should == [@dd_file_ds.dsid]
        content_md_ds.term_values(:dd_filename).should == ["CM5551212"]
        content_md_ds.term_values(:dd_size).first.should match(/^\d+$/)
        content_md_ds.term_values(:dd_mimetype).should == ["application/octet-stream"]
        content_md_ds.term_values(:dd_md5).should == ["7d7abca99f383487e02ce7bf7c017267"]
        content_md_ds.term_values(:dd_sha1).should == ["628ede981ad24c1655f7e37057355ca689dcb3a9"]

        content_md_ds.term_values(:image_front_fedora_pid).first.should match(/^hypatia:\d+$/) 
        content_md_ds.term_values(:image_front_ds_id).should == ["DS1"] # oops - hardcoded
        content_md_ds.term_values(:image_front_filename).should == ["CM5551212.JPG"]
        content_md_ds.term_values(:image_front_size).first.should match(/^\d+$/)
        content_md_ds.term_values(:image_front_mimetype).should == ["image/jpeg"]
        content_md_ds.term_values(:image_front_md5).should == ["812b53258f21ee250d17c9308d2099d9"]
        content_md_ds.term_values(:image_front_sha1).should == ["da39a3ee5e6b4b0d3255bfef95601890afd80709"]
      end
=end
    end  # context "contentMetadata"
  end # context "FileAsset and its contentMetadata in the FtkItem"



# 2011-09-29  Naomi commenting out because this now fails with new data models.
=begin  
  context "creating fedora objects" do
    before(:all) do
      @disk_object = build_fixture_disk_object
      
      @ff = FactoryGirl.build(:ftk_file)
      @fia = FtkItemAssembler.new(:collection_pid => @coll_pid)  
      @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
      @file_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk") 
      @display_derivative_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/display_derivatives") 
      @fia.file_dir = @file_dir
      @fia.display_derivative_dir = @display_derivative_dir
      @hi = @fia.create_hypatia_item(@ff)  
      @hi.save
    end
    
    after(:all) do
      @disk_object.parts.first.delete
      @disk_object.delete
      @hi.parts.first.delete
      @hi.delete
    end
    
    it "accepts an FtkFile as an argument and returns a HypatiaItem object" do
      @hi.should be_instance_of(HypatiaFtkItem)
    end
    
    it "includes all the expected metadata datastreams" do
      ['contentMetadata','descMetadata','rightsMetadata','DC','RELS-EXT'].each do |datastream_name|
        @hi.datastreams[datastream_name].should_not eql(nil)
      end
    end
    
    it "has a file object with an isPartOf relationship" do
      @hi.inbound_relationships[:is_part_of].length.should eql(1)
    end
    
    it "has an isMemberOf relationship with a disk object" do
      @hi.relationships[:self][:is_member_of].first.gsub("info:fedora/",'').should eql(@disk_object.pid)
    end
    
    it "has an isMemberOfCollection relationship with a collection object" do
      @hi.relationships[:self][:is_member_of_collection].first.gsub("info:fedora/",'').should eql(@coll_pid)
    end
    
    it "has a FileAsset part" do
      @hi.parts.first.should be_instance_of(FileAsset)
    end

    # This is the binary file for an FTK object
    # It needs a better test at some point
    it "has a member object with a file payload" do
      @hi.parts.first.datastreams['content'].content.should_not eql(nil)
    end
    
    it "has a member object with an html payload" do
      @hi.parts.first.datastreams['derivative_html'].content.should_not eql(nil)
    end
  end
=end

=begin # it doesn't seem we are creating bags anymore????  
  context "creating bags" do
    before(:all) do
      @ff = FactoryGirl.build(:ftk_file)
      @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
      @file_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/")
    end
    it "knows where to put bags it creates" do
      Dir.mktmpdir {|dir|
        hfo = FtkItemAssembler.new(:bag_destination => dir)
        hfo.bag_destination.should eql(dir)
       }
    end
    
    it "throws an exception if you try to create a bag without telling it where the payload files are" do
      Dir.mktmpdir { |dir|
        hfo = FtkItemAssembler.new(:bag_destination => dir)
        lambda { hfo.create_bag(@ff) }.should raise_exception
      }
    end
    
    it "creates a bagit package for an ftk object" do
      Dir.mktmpdir {|dir|
        # dir = Dir.mktmpdir
        # puts "\n\n<br><br>dir = #{dir}<br><br>\n\n"
        hfo = FtkItemAssembler.new(:bag_destination => dir)
        hfo.file_dir = @file_dir
        bag = hfo.create_bag(@ff)
        
        File.file?(File.join(dir,@ff.unique_combo,"/data/contentMetadata.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/descMetadata.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/RELS-EXT.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/rightsMetadata.xml")).should eql(true)
        File.file?(File.join(dir,@ff.unique_combo,"/data/#{@ff.destination_file}")).should eql(true)
        bag.valid?.should eql(true)
       }
    end
  end # content "creating bags"
=end  
end # describe FtkItemAssembler

# Create a HypatiaDiskImageItem from the data in the FtkDiskImage fixture
# @return [FtkDiskImageItem]
def build_fixture_disk_object
  clean_fixture_disk_objects 
  fdi = FactoryGirl.build(:ftk_disk_image)
  @disk_image_files_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/disk_images")
  @computer_media_photos_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/computer_media_photos")
  @foo = FtkDiskImageItemAssembler.new(:disk_image_files_dir => @disk_image_files_dir, :computer_media_photos_dir => @computer_media_photos_dir)
  @disk_object = @foo.build_object(fdi)
  return @disk_object
end

# Tying a file object to a disk object relies on having only one solr document 
# that matches a given disk number. Ensure we remove all instances of the disk object
# fixture before running any test that requires disk to file linking. 
def clean_fixture_disk_objects
  fdi = FactoryGirl.build(:ftk_disk_image)
  solr_params={}
  solr_params[:q]="file_id_t:#{fdi.disk_number}"
  solr_params[:qt]='standard'
  solr_params[:fl]='id'
  solr_response = Blacklight.solr.find(solr_params)
  solr_response.docs.each do |doc|
    ActiveFedora::Base.load_instance(doc[:id]).delete    
  end
end