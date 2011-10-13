require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
#require File.join(File.dirname(__FILE__), "/../../lib/ftk_processor")
#require File.join(File.dirname(__FILE__), "/../../lib/ftk_item_assembler")
#require File.join(File.dirname(__FILE__), "/../../app/models/hypatia_ftk_item")

#require 'rubygems'
#require 'ruby-debug'
require 'factory_girl'
require File.join(File.dirname(__FILE__), "/../fixtures/ftk/factories/ftk_files.rb")
#require 'tempfile'

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
    after(:all) do
      delete_fixture(@coll_pid)
    end
    it "can instantiate" do
      hfo = FtkItemAssembler.new
      hfo.class.should eql(FtkItemAssembler)
    end
    it "takes a fedora config file as an argument" do
      hfo = FtkItemAssembler.new(:fedora_config => @fedora_config)
      hfo.fedora_config.should eql(@fedora_config)
    end
    it "sets the pid of the collection object these items belong to" do
      hfo = FtkItemAssembler.new
      hfo.collection_pid = "hypatia:fixture_coll"
      hfo.collection_pid.should eql("hypatia:fixture_coll")
    end
=begin  no longer duplicated in item object
    it "gets the name of the collection it belongs to" do
      hfo = FtkItemAssembler.new(:collection_pid => "hypatia:fixture_xanadu_collection")
      hfo.collection_name.should eql("Keith Henson. Papers relating to Project Xanadu, XOC and Eric Drexler")
    end
=end
    it "processes an FTK report" do
      hfo = FtkItemAssembler.new(:fedora_config => @fedora_config)
      hfo.expects(:create_hypatia_item).at_least(56).returns(nil)
      hfo.process(@ftk_report,@file_dir,@display_derivative_dir)
      hfo.ftk_report.should eql(@ftk_report)
      hfo.file_dir.should eql(@file_dir)
      hfo.display_derivative_dir.should eql(@display_derivative_dir)
    end
  end
  
  context "creating datastreams" do
    before(:all) do
      delete_fixture(@coll_pid)
      import_fixture(@coll_pid)
      @ff = FactoryGirl.build(:ftk_file)
      @fedora_config = File.join(File.dirname(__FILE__), "/../../config/fedora.yml")
      @hfo = FtkItemAssembler.new(:fedora_config => @fedora_config, :collection_pid => "hypatia:fixture_xanadu_collection")
    end
    after(:all) do
      delete_fixture("hypatia:fixture_xanadu_collection")
    end
    it "creates a descMetadata file" do
      doc = Nokogiri::XML(@hfo.buildDescMetadata(@ff))
=begin  no longer duplicated in item object      
      @hfo.collection_name.should eql("Keith Henson. Papers relating to Project Xanadu, XOC and Eric Drexler")
=end
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql(@ff.filename)
      doc.xpath("/mods:mods/mods:relatedItem[@displayLabel='Appears in']/mods:titleInfo/mods:title/text()").to_s.should eql(@ff.title)
      doc.xpath("/mods:mods/mods:location/text()").to_s.should eql("CM5551212 (Punch Cards)")
      doc.xpath("/mods:mods/mods:location/mods:physicalLocation[@type='disk']/text()").to_s.should eql(@ff.disk_image_number)
      doc.xpath("/mods:mods/mods:location/mods:physicalLocation[@type='filepath']/text()").to_s.should eql(@ff.filepath)
      doc.xpath("/mods:mods/mods:originInfo/mods:dateCreated/text()").to_s.should eql(@ff.file_creation_date)
      doc.xpath("/mods:mods/mods:originInfo/mods:dateOther[@type='last_accessed']/text()").to_s.should eql(@ff.file_accessed_date)
      doc.xpath("/mods:mods/mods:originInfo/mods:dateOther[@type='last_modified']/text()").to_s.should eql(@ff.file_modified_date)
      doc.xpath("/mods:mods/mods:typeOfResource/text()").to_s.should eql(@ff.type)
      doc.xpath("/mods:mods/mods:physicalDescription/mods:form/text()").to_s.should eql(@ff.medium)
    end
    it "creates a contentMetadata file" do
      doc = Nokogiri::XML(@hfo.buildContentMetadata(@ff,"fake_pid","fake_object_id"))
      doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
      doc.xpath("/contentMetadata/@objectId").to_s.should eql("fake_pid")
      doc.xpath("/contentMetadata/resource/@type").to_s.should eql("analysis")
      doc.xpath("/contentMetadata/resource/file/@id").to_s.should eql(@ff.filename)
      doc.xpath("/contentMetadata/resource/file/@objectId").to_s.should_not eql("fake_object_id")
      doc.xpath("/contentMetadata/resource/file/@format").to_s.should eql(@ff.filetype)
      doc.xpath("/contentMetadata/resource/file/location/@type").to_s.should eql("filesystem")
      doc.xpath("/contentMetadata/resource/file/location/text()").to_s.should eql(@ff.export_path)      
      doc.xpath("/contentMetadata/resource/file/checksum[@type='md5']/text()").to_s.should eql(@ff.md5)      
      doc.xpath("/contentMetadata/resource/file/checksum[@type='sha1']/text()").to_s.should eql(@ff.sha1)
    end
    it "creates a rightsMetdata file" do
      doc = Nokogiri::XML(@hfo.buildRightsMetadata(@ff))
      doc.xpath("/xmlns:rightsMetadata/xmlns:access[@type='discover']/xmlns:machine/xmlns:group/text()").to_s.should eql(@ff.access_rights.downcase)
      doc.xpath("/xmlns:rightsMetadata/xmlns:access[@type='read']/xmlns:machine/xmlns:group/text()").to_s.should eql(@ff.access_rights.downcase)
    end
    it "creates a RELS-EXT datastream" do
      doc = Nokogiri::XML(@hfo.buildRelsExt(@ff))
      doc.xpath("/rdf:RDF/rdf:Description/hydra:isGovernedBy/@rdf:resource").to_s.should eql("info:fedora/hypatia:fixture_xanadu_apo")
    end
  end
  
  context "FileAsset creation for FTK file" do
    before(:all) do
      delete_fixture(@coll_pid)
      import_fixture(@coll_pid)
      @assembler = FtkItemAssembler.new(:collection_pid => "hypatia:fixture_coll2")
      @ftk_file_object = FactoryGirl.build(:ftk_file)
      ftk_item_object = HypatiaFtkItem.new
      @assembler.file_dir = "spec/fixtures/ftk"
      @assembler.display_derivative_dir = "spec/fixtures/ftk/display_derivatives" 
      @file_asset = @assembler.create_file_asset(ftk_item_object, @ftk_file_object)
      @ftk_item_pid = ftk_item_object.internal_uri
    end
    
    after(:all) do
      @file_asset.delete
    end
    
    it "creates the correct FileAsset object for the FTK file and its display derivative" do
      @file_asset.should be_instance_of(FileAsset) # model
      @file_asset.relationships[:self][:is_part_of].should == ["#{@ftk_item_pid}"]
      # datastreams:  DC, RELS-EXT, descMetadata, content, derivative-html
      @file_asset.datastreams.size.should == 5
      # content file datastream:
      content_ds = @file_asset.datastreams["content"]
      content_ds[:dsLabel].should ==  @ftk_file_object.filename 
      content_ds[:dsLabel].should == "BURCH1" 
      #  can't get mime_type here, even though it is set when the datastream is written to Fedora
      # display derivative datastream
      deriv_ds = @file_asset.datastreams["derivative_html"]
      deriv_ds[:dsLabel].should ==  @ftk_file_object.display_deriv_fname
      deriv_ds[:dsLabel].should == "BURCH1.htm"
      deriv_ds[:mime_type].should == "text/html"
      # descMetadata:
      desc_md_ds_fields_hash = @file_asset.datastreams["descMetadata"].fields
      # extent value (file size) is computed by FileAsset.add_file_datastream
      desc_md_ds_fields_hash[:extent][:values].first.should match(/(bytes|KB|MB|GB|TB)$/)
      desc_md_ds_fields_hash[:title][:values].should == ["FileAsset for FTK file #{@ftk_file_object.filename}"]
    end
    
    it "creates the correct FileAsset object when there is no display derivative" do
      pending
    end
    
  end

# 2011-09-29  Naomi commenting out because this now fails with new data models.
=begin  
  context "creating fedora objects" do
    before(:all) do
      @disk_object = build_fixture_disk_object
      
      @ff = FactoryGirl.build(:ftk_file)
      @fia = FtkItemAssembler.new(:collection_pid => "hypatia:fixture_coll")  
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
      @hi.relationships[:self][:is_member_of_collection].first.gsub("info:fedora/",'').should eql("hypatia:fixture_coll")
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
  end
end

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