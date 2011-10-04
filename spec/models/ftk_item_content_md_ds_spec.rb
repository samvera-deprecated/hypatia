require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaFTKItemContentMetadataDS do
  before(:all) do
    @content_md_ds = HypatiaFTKItemContentMetadataDS.from_xml(active_fedora_fixture("ftk_item_content_metadata.xml"))
  end
    
  it "should have :my_fedora_id value from the objectId attribute on the <contentMetadata> element" do
    @content_md_ds.term_values(:my_fedora_id).should == ["hypatia:fixture_ftk_file_item"] 
  end
  
  it "should have :file_asset_fedora_id value from the objectId attribute on the <resource> element" do
    @content_md_ds.term_values(:file_asset_fedora_id).should == ["hypatia:fixture_file_asset_for_ftk_file_item"] # pid of FileAsset object
  end
  
  it "should hook to the proper datastream for the 'content' and have correct metadata for that datastream" do
    @content_md_ds.term_values(:content_ds_id).should == ["content"]
    @content_md_ds.term_values(:content_filename).should == ["BURCH1"] # id attribute on <file> element
    @content_md_ds.term_values(:content_size).should == ["35654"]
    @content_md_ds.term_values(:content_format).should == ["BINARY"] # DOR controlled vocabulary
    @content_md_ds.term_values(:content_mimetype).should == ["application/octet-stream"]
    @content_md_ds.term_values(:content_md5).should == ["5E3A2508EA8A8D7E62657D99DAE503ED"]
    @content_md_ds.term_values(:content_sha1).should == ["E876FA363FAFDC6784C5EE75E8F9EA9FF11EC9FF"]
  end
  
  it "should hook to the proper datastream for the 'derivative_html' and have correct metadata for that datastream" do
    @content_md_ds.term_values(:html_ds_id).should == ["derivative_html"]
    @content_md_ds.term_values(:html_filename).should == ["BURCH1.html"] # id attribute on <file> element
    @content_md_ds.term_values(:html_size).should == ["12346"]
    @content_md_ds.term_values(:html_format).should == ["HTML"] # DOR controlled vocabulary
    @content_md_ds.term_values(:html_mimetype).should == ["text/html"]
    @content_md_ds.term_values(:html_md5).should == ["5E3A2508EA8A8D7E62657D99DAE503EDMORE"]
    @content_md_ds.term_values(:html_sha1).should == ["E876FA363FAFDC6784C5EE75E8F9EA9FF11EC9FFDIFF"]
  end

end