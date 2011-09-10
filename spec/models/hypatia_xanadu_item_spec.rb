require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaXanaduItem do
  
  before(:each) do
    # Fedora::Repository.stubs(:instance).returns(stub('xanadu_stub').as_null_object)
    @hypatia_xanadu_item = HypatiaXanaduItem.new
  end
  
  after(:all) do
    ActiveFedora.init()
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @hypatia_xanadu_item.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaItemDescMetadataDS" do
    @hypatia_xanadu_item.datastreams.should have_key("descMetadata")
    @hypatia_xanadu_item.datastreams["descMetadata"].should be_instance_of(HypatiaItemDescMetadataDS)
  end

  it "should have a contentMetadata datastream of type HypatiaItemContentMetadataDS" do
    @hypatia_xanadu_item.datastreams.should have_key("contentMetadata")
    @hypatia_xanadu_item.datastreams["contentMetadata"].should be_instance_of(HypatiaItemContentMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @hypatia_xanadu_item.datastreams.should have_key("rightsMetadata")
    @hypatia_xanadu_item.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a sets relationship" do
    @hypatia_xanadu_item.should respond_to(:sets)
  end
  
end