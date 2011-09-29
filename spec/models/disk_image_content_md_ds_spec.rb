require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaDiskImgContentMDDS do
  before(:all) do
    @content_md_ds = HypatiaDiskImgContentMDDS.from_xml(active_fedora_fixture("disk_image_content_metadata.xml"))
  end
    
  it "should have :my_fedora_id value from the objectId attribute on the <contentMetadata> element" do
    @content_md_ds.term_values(:my_fedora_id).should == ["hypatia:fixture_disk_image_item"] 
  end
  
  it "should hook to the proper dd FileAsset object and have correct metadata for that object" do
    @content_md_ds.term_values(:dd_fedora_pid).should == ["hypatia:fixture_file_asset_dd_for_media_item"] 
    @content_md_ds.term_values(:dd_ds_id).should == ["DS1"]
    @content_md_ds.term_values(:dd_filename).should == ["CM058.dd"]  # must match LABEL attribute of datastream in EAD FileAsset object
    @content_md_ds.term_values(:dd_size).should == ["47570"]
    @content_md_ds.term_values(:dd_mimetype).should == ["application/octet-stream"]
    @content_md_ds.term_values(:dd_md5).should == ["12"]
    @content_md_ds.term_values(:dd_sha1).should == ["34"]
  end
  
  it "should hook to the proper image_front FileAsset object and have correct metadata for that object" do
    @content_md_ds.term_values(:image_front_fedora_pid).should == ["hypatia:fixture_file_asset_image1_for_media_item"] 
    @content_md_ds.term_values(:image_front_ds_id).should == ["DS1"]
    @content_md_ds.term_values(:image_front_filename).should == ["fixture_media_item_front.jpg"]  # must match LABEL attribute of datastream in coll image FileAsset object
    @content_md_ds.term_values(:image_front_size).should == ["302081"]
    @content_md_ds.term_values(:image_front_mimetype).should == ["image/jpeg"]
    @content_md_ds.term_values(:image_front_md5).should == ["56"]
    @content_md_ds.term_values(:image_front_sha1).should == ["78"]
  end

  it "should hook to the proper image_back FileAsset object and have correct metadata for that object" do
    @content_md_ds.term_values(:image_back_fedora_pid).should == ["hypatia:fixture_file_asset_image2_for_media_item"] 
    @content_md_ds.term_values(:image_back_ds_id).should == ["DS1"]
    @content_md_ds.term_values(:image_back_filename).should == ["fixture_media_item_back.jpg"]  # must match LABEL attribute of datastream in coll image FileAsset object
    @content_md_ds.term_values(:image_back_size).should == ["302084"]
    @content_md_ds.term_values(:image_back_mimetype).should == ["image/jpeg"]
    @content_md_ds.term_values(:image_back_md5).should == ["90"]
    @content_md_ds.term_values(:image_back_sha1).should == ["666"]
  end
end