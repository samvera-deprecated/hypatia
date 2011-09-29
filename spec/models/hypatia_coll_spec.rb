require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaCollection do
  
  before(:all) do
    @hypatia_coll = HypatiaCollection.new
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @hypatia_coll.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaCollDescMetadataDS" do
    @hypatia_coll.datastreams.should have_key("descMetadata")
    @hypatia_coll.datastreams["descMetadata"].should be_instance_of(HypatiaCollDescMetadataDS)
  end

  it "should have a contentMetadata datastream of type HypatiaCollContentMetadataDS" do
    @hypatia_coll.datastreams.should have_key("contentMetadata")
    @hypatia_coll.datastreams["contentMetadata"].should be_instance_of(HypatiaCollContentMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @hypatia_coll.datastreams.should have_key("rightsMetadata")
    @hypatia_coll.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a members relationship (a collection has members)" do
    @hypatia_coll.should respond_to(:members)
  end
  
  it "should not have a sets relationship (a collection belongs to no set)" do
    @hypatia_coll.should_not respond_to(:sets)
  end
  
  it "should have a parts relationship (for FileAssets such as EAD, image, etc.)" do
    @hypatia_coll.should respond_to(:parts)
  end
  
end