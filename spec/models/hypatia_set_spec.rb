require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaSet do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub('set_stub').as_null_object)
    @hypatia_set = HypatiaSet.new
  end
  
  after(:all) do
    ActiveFedora.init()
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @hypatia_set.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaSetDescMetadataDS" do
    @hypatia_set.datastreams.should have_key("descMetadata")
    @hypatia_set.datastreams["descMetadata"].should be_instance_of(HypatiaSetDescMetadataDS)
  end

  it "should have a identityMetadata datastream of type DorIdentityMetadataDS" do
    @hypatia_set.datastreams.should have_key("identityMetadata")
    @hypatia_set.datastreams["identityMetadata"].should be_instance_of(DorIdentityMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @hypatia_set.datastreams.should have_key("rightsMetadata")
    @hypatia_set.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a members relationship" do
    @hypatia_set.should respond_to(:members)
  end
  
end