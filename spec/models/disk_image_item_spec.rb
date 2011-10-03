require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaDiskImageItem do
  
  before(:all) do
    @disk_img_item = HypatiaDiskImageItem.new
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @disk_img_item.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a descMetadata datastream of type HypatiaItemDescMetadataDS" do
    @disk_img_item.datastreams.should have_key("descMetadata")
    @disk_img_item.datastreams["descMetadata"].should be_instance_of(HypatiaItemDescMetadataDS)
  end

  it "should have a contentMetadata datastream of type HypatiaDiskImgContentMDDS" do
    @disk_img_item.datastreams.should have_key("contentMetadata")
    @disk_img_item.datastreams["contentMetadata"].should be_instance_of(HypatiaDiskImgContentMetadataDS)
  end

  it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
    @disk_img_item.datastreams.should have_key("rightsMetadata")
    @disk_img_item.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  end
    
  it "should have a collection relationship (a disk image belongs to a collection)" do
    @disk_img_item.should respond_to(:collections)
  end

  it "should have a sets relationship (a disk image can belong to no set)" do
    @disk_img_item.should respond_to(:sets)
  end
  
  it "should have a members relationship (a disk image can have members, such as ftk file items)" do
    @disk_img_item.should respond_to(:members)
  end
  
  it "should have a parts relationship (for FileAssets such as dd, image, etc.)" do
    @disk_img_item.should respond_to(:parts)
  end

end