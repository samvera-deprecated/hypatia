require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaCollContentMetadataDS do
  before(:all) do
    @content_md_ds = HypatiaCollContentMetadataDS.from_xml(active_fedora_fixture("coll_content_metadata.xml"))
  end
    
  it "should have :my_fedora_id value from the objectId attribute on the <contentMetadata> element" do
    @content_md_ds.term_values(:my_fedora_id).should == ["hypatia:fixture_coll2"] 
  end
  
  it "should hook to the proper EAD FileAsset object and have correct metadata for that object" do
    @content_md_ds.term_values(:ead_fedora_pid).should == ["hypatia:fixture_file_asset_ead_for_coll"] # pid of EAD FileAsset object
    @content_md_ds.term_values(:ead_ds_label).should == ["coll_ead.xml"]  # must match LABEL attribute of datastream in EAD FileAsset object
    @content_md_ds.term_values(:ead_size).should == ["47570"]
    @content_md_ds.term_values(:ead_md5).should == ["856d7eae922f80e68c954d2e3521f74a"]
    @content_md_ds.term_values(:ead_sha1).should == ["1a79a23e7827ee62370850def76afdeccf3fbadb"]
  end
  
  it "should hook to the proper image FileAsset object and have correct metadata for that object" do
    @content_md_ds.term_values(:image_fedora_pid).should == ["hypatia:fixture_file_asset_image_for_coll"] # pid of collection image FileAsset object
    @content_md_ds.term_values(:image_ds_label).should == ["fixture_coll_image.jpg"]  # must match LABEL attribute of datastream in coll image FileAsset object
    @content_md_ds.term_values(:image_size).should == ["302080"]
    @content_md_ds.term_values(:image_md5).should == ["856d7eae922f80e68c954d2e3521f74ab"]
    @content_md_ds.term_values(:image_sha1).should == ["1a79a23e7827ee62370850def76afdeccf3fbadbc"]
  end

end