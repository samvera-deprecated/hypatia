require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaItemDescMetadataDS do
  
  it "should have the correct :title term value" do
    desc_md_ds = HypatiaItemDescMetadataDS.from_xml(active_fedora_fixture("item_desc_metadata.xml"))
    desc_md_ds.term_values(:title).should == ["CM01"]
    desc_md_ds.term_values(:title_info, :title).should == ["CM01"]
  end
  
  it "should get terms from inside the physical description element" do
    desc_md_ds = HypatiaItemDescMetadataDS.from_xml(active_fedora_fixture("item_desc_metadata.xml"))
    desc_md_ds.term_values(:digital_origin).should == ["born digital"]
  end
  
  it "should allow multiple values for a term" do
    desc_md_ds = HypatiaItemDescMetadataDS.from_xml(active_fedora_fixture("item_desc_metadata.xml"))
    desc_md_ds.term_values(:extent).length.should == 2
    desc_md_ds.term_values(:extent).should == ["1.0 computer media", "hard drive"]
  end
  
  it "should correct assign terms based on a combination of element name and attribute value" do
    desc_md_ds = HypatiaItemDescMetadataDS.from_xml(active_fedora_fixture("item_desc_metadata.xml"))
    desc_md_ds.term_values(:local_id).should == ["CM01"]
  end

end