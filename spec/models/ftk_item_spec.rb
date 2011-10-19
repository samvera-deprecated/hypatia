require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaFtkItem do
  
  before(:each) do
    @hypatia_ftk_item = HypatiaFtkItem.new
  end
  
  after(:all) do
    ActiveFedora.init()
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @hypatia_ftk_item.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaFTKItemDescMetadataDS" do
    @hypatia_ftk_item.datastreams.should have_key("descMetadata")
    @hypatia_ftk_item.datastreams["descMetadata"].should be_instance_of(HypatiaFTKItemDescMetadataDS)
  end

  it "should have a contentMetadata datastream of type HypatiaFTKItemContentMetadataDS" do
    @hypatia_ftk_item.datastreams.should have_key("contentMetadata")
    @hypatia_ftk_item.datastreams["contentMetadata"].should be_instance_of(HypatiaFTKItemContentMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @hypatia_ftk_item.datastreams.should have_key("rightsMetadata")
    @hypatia_ftk_item.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a collection relationship (an ftk item can belong to a collection)" do
    @hypatia_ftk_item.should respond_to(:collections)
  end

  it "should have a sets relationship (an ftk item can belong to sets)" do
    @hypatia_ftk_item.should respond_to(:sets)
  end
  
  it "should not have a members relationship (an ftk item cannot have members)" do
    @hypatia_ftk_item.should_not respond_to(:members)
  end
  
  it "should have a parts relationship (for FileAsset with the content and display derivative files)" do
    @hypatia_ftk_item.should respond_to(:parts)
  end
  
end