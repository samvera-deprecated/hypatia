require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaItemContentMetadataDS do
  
#  ["", "", "", "", ""]
  
  it "should have term values from resource element attributes" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata.xml"))
#    content_md_ds.term_values(:resource, :resource_type).should == ["disk-image", "photo", "photo", "analysis", "analysis"]
#    content_md_ds.term_values(:resource, :resource_id).should == ["disk-image", "photo-1", "photo-2", "analysis-text", "analysis-contents"]
    pending
  end
  
  it "should have the right number of resource and file objects" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata.xml"))
#    content_md_ds.term_values(:resource).length.should == 5
#    content_md_ds.term_values(:resource, :file).length.should == 5
    pending
  end

end