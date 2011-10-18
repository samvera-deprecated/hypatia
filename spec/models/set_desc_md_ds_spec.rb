require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaSetDescMetadataDS do
  before(:all) do
    @desc_md_ds = HypatiaSetDescMetadataDS.from_xml(active_fedora_fixture("set_desc_metadata.xml"))
  end
    
  it "should have the correct :display_name term value" do
    @desc_md_ds.term_values(:display_name).should == ["set title"]
  end
  
  it "should have the correct :title term value" do
    @desc_md_ds.term_values(:title).should == ["set title"]
    @desc_md_ds.term_values(:title_info, :title).should == ["set title"]
  end

  it "should have the correct :local_id term value" do
    @desc_md_ds.term_values(:local_id).should == ["local id"]
  end
  
  it "should have the correct :create_date term value" do
    @desc_md_ds.term_values(:create_date).should == ["create date"]
  end

  it "should have correct :scope_and_contents term values" do
    @desc_md_ds.term_values(:scope_and_content).should == ["scope and contents"]
  end
  
  it "should have the correct extent values" do
    @desc_md_ds.term_values(:extent).length.should == 2
    @desc_md_ds.term_values(:extent).should == ["extent1", "extent2"]
  end

  it "should have correct :note values" do
    @desc_md_ds.term_values(:note).should == ["note1", "note2", "note3"]
  end

end