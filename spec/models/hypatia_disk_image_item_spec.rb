require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaDiskImageItem do
  
  before(:each) do
    @item = HypatiaDiskImageItem.new
  end
  
  after(:all) do
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @item.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaItemDescMetadataDS" do
    @item.datastreams.should have_key("descMetadata")
    @item.datastreams["descMetadata"].should be_instance_of(HypatiaItemDescMetadataDS)
  end

  it "should have a contentMetadata datastream of type HypatiaItemContentMetadataDS" do
    @item.datastreams.should have_key("contentMetadata")
    @item.datastreams["contentMetadata"].should be_instance_of(HypatiaItemContentMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @item.datastreams.should have_key("rightsMetadata")
    @item.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a sets relationship" do
    @item.should respond_to(:sets)
    @item.should respond_to(:part_of)
  end
end