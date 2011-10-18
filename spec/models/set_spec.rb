require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaSet do
  
  before(:all) do
    @hypatia_set = HypatiaSet.new
  end
  
  after(:all) do
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @hypatia_set.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaSetDescMetadataDS" do
    @hypatia_set.datastreams.should have_key("descMetadata")
    @hypatia_set.datastreams["descMetadata"].should be_instance_of(HypatiaSetDescMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @hypatia_set.datastreams.should have_key("rightsMetadata")
    @hypatia_set.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a collection relationship (a set belongs to a collection)" do
    @hypatia_set.should respond_to(:collections)
  end

  it "should have a members relationship (a set has members)" do
    @hypatia_set.should respond_to(:members)
  end
  
  it "should not have a parts relationship (a set has no attached FileAssets)" do
    @hypatia_coll.should_not respond_to(:parts)
  end
  
end