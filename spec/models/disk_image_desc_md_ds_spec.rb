require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaDiskImgDescMetadataDS do
  before(:all) do
    @desc_md_ds = HypatiaDiskImgDescMetadataDS.from_xml(active_fedora_fixture("disk_image_desc_metadata.xml"))
  end
    
  it "should have the correct :display_name term value" do
    @desc_md_ds.term_values(:display_name).should == ["CM058"]
  end
  
  it "should have the correct :title term value" do
    @desc_md_ds.term_values(:title).should == ["CM058"]
    @desc_md_ds.term_values(:title_info, :title).should == ["CM058"]
  end
  
  it "should have the correct :local_id term value" do
    @desc_md_ds.term_values(:local_id).should == ["M1437"]
  end

  it "should have the correct :extent term value" do
    @desc_md_ds.term_values(:extent).should == ["3.5 inch Floppy Disk"]
  end

  it "should have the correct :digital_origin term value" do
    @desc_md_ds.term_values(:digital_origin).should == ["born digital"]
  end

end