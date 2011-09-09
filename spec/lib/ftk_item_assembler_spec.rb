require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.join(File.dirname(__FILE__), "/../../lib/ftk_file")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_processor")
require File.join(File.dirname(__FILE__), "/../../lib/ftk_item_assembler")
require File.join(File.dirname(__FILE__), "/../../app/models/hypatia_ftk_item")
# require File.join(File.dirname(__FILE__), "/../../lib/hypatia_file")

require 'rubygems'
require 'ruby-debug'
require 'factory_girl'
require 'tempfile'
require File.join(File.dirname(__FILE__), "/../fixtures/ftk/factories/ftk_files.rb")


describe FtkItemAssembler do
  before(:all) do
    @fedora_config = File.join(File.dirname(__FILE__), "/../../config/fedora.yml")
    @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
    @file_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk/files")
  end
  context "basic behavior" do
    it "can instantiate" do
      hfo = FtkItemAssembler.new
      hfo.class.should eql(FtkItemAssembler)
    end
    it "takes a fedora config file as an argument" do
      hfo = FtkItemAssembler.new(:fedora_config => @fedora_config)
      hfo.fedora_config.should eql(@fedora_config)
    end
    it "processes an FTK report" do
      hfo = FtkItemAssembler.new(:fedora_config => @fedora_config)
      hfo.expects(:create_hypatia_item).at_least(56).returns(nil)
      hfo.process(@ftk_report,@file_dir)
      hfo.ftk_report.should eql(@ftk_report)
      hfo.file_dir.should eql(@file_dir)
    end
  end
  
  context "creating datastreams" do
    before(:all) do
      @ff = FactoryGirl.build(:ftk_file)
      @fedora_config = File.join(File.dirname(__FILE__), "/../../config/fedora.yml")
      @hfo = FtkItemAssembler.new(:fedora_config => @fedora_config)
    end
    it "creates a descMetadata file" do
      doc = Nokogiri::XML(@hfo.buildDescMetadata(@ff))
      doc.xpath("/mods:mods/mods:titleInfo/mods:title/text()").to_s.should eql(@ff.title)
      doc.xpath("/mods:mods/mods:typeOfResource/text()").to_s.should eql(@ff.type)
      doc.xpath("/mods:mods/mods:physicalDescription/mods:form/text()").to_s.should eql(@ff.medium)
    end
    it "creates a contentMetadata file" do
      doc = Nokogiri::XML(@hfo.buildContentMetadata(@ff))
      doc.xpath("/contentMetadata/@type").to_s.should eql("born-digital")
      doc.xpath("/contentMetadata/@objectId").to_s.should eql(@ff.unique_combo)
      doc.xpath("/contentMetadata/resource/@type").to_s.should eql("analysis")
      doc.xpath("/contentMetadata/resource/file/@id").to_s.should eql(@ff.filename)
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
  
  context "creating fedora objects" do
    before(:all) do
      @ff = FactoryGirl.build(:ftk_file)
      @ff.export_path = 'files/stephenjaygould.jpeg'
      @fia = FtkItemAssembler.new()   
      ActiveFedora.init()
      @ftk_report = File.join(File.dirname(__FILE__), "/../fixtures/ftk/Gould_FTK_Report.xml")
      @file_dir = File.join(File.dirname(__FILE__), "/../fixtures/ftk") 
      @fia.file_dir = @file_dir
      # hypatia_item = HypatiaFtkItem.new
      # hypatia_item.save
      @hi = @fia.create_hypatia_item(@ff)  
      # puts Fedora::Repository.instance.fedora_version      
      # @hi = HypatiaFtkItem.new
      # puts @hi.pid
      @hi.save
    end
    
    it "accepts an FtkFile as an argument and returns a HypatiaItem object" do
      @hi.should be_instance_of(HypatiaFtkItem)
    end
    
    it "includes all the expected metadata datastreams" do
      ['contentMetadata','descMetadata','rightsMetadata','DC','RELS-EXT'].each do |datastream_name|
        @hi.datastreams[datastream_name].should_not eql(nil)
      end
    end
    
    it "has a file object with an isMemberOf relationship" do
      @hi.inbound_relationships[:is_member_of].length.should eql(1)
      # {:is_member_of=>["info:fedora/changeme:54"]}
    end

    # This is the binary file for an FTK object
    # It needs a better test at some point
    it "has a member object with a file payload" do
      @hi.members.first.datastreams['content'].content.should_not eql(nil)
    end
    
  end
  
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
    
    it "creates a bagit package for an ftk_file" do
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