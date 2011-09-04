require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaFtkItem do
  
  before(:each) do
    Fedora::Repository.stubs(:instance).returns(stub('stub').as_null_object)
    @hypatia_ftk_item = HypatiaFtkItem.new
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @hypatia_ftk_item.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaItemDescMetadataDS" do
    @hypatia_ftk_item.datastreams.should have_key("descMetadata")
    @hypatia_ftk_item.datastreams["descMetadata"].should be_instance_of(HypatiaItemDescMetadataDS)
  end

  it "should have a contentMetadata datastream of type HypatiaItemContentMetadataDS" do
    @hypatia_ftk_item.datastreams.should have_key("contentMetadata")
    @hypatia_ftk_item.datastreams["contentMetadata"].should be_instance_of(HypatiaItemContentMetadataDS)
  end

  it "should have a identityMetadata datastream of type DorIdentityMetadataDS" do
    @hypatia_ftk_item.datastreams.should have_key("identityMetadata")
    @hypatia_ftk_item.datastreams["identityMetadata"].should be_instance_of(DorIdentityMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @hypatia_ftk_item.datastreams.should have_key("rightsMetadata")
    @hypatia_ftk_item.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a sets relationship" do
    @hypatia_ftk_item.should respond_to(:sets)
  end
  
end