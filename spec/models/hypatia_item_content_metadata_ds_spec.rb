require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaItemContentMetadataDS do
  
  it "should have something at the contentMetadata level" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata_ds_fixture.xml"))
#    puts content_md_ds.find_by_terms(:contentMetadata).inspect # emtpy arry
    pending
  end
  
  it "should have term values from content element attributes" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata_ds_fixture.xml"))
    content_md_ds.term_values(:cont_oid).length.should == 1
    content_md_ds.term_values(:cont_oid).should == ["druid:tk694zs2244"]
    content_md_ds.term_values(:content_oid).should == "druid:tk694zs2244"
    pending
  end

  it "should have term values from resource element attributes" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata_ds_fixture.xml"))
    content_md_ds.term_values(:resource, :resource_type).length.should == 5
    pending
  end
  
  it "should have the right number of resource and file objects" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata_ds_fixture.xml"))
    content_md_ds.term_values(:resource).length.should == 5
    content_md_ds.term_values(:resource, :file).length.should == 5
    pending
  end

end