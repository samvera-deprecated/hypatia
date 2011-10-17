require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaFTKItemDescMetadataDS do
  before(:all) do
    @desc_md_ds = HypatiaFTKItemDescMetadataDS.from_xml(active_fedora_fixture("ftk_item_desc_metadata.xml"))
  end
    
  it "should have the correct :filename value" do
    @desc_md_ds.term_values(:filename).should == ["BU3A5"]
  end

  it "should have the correct :display_name value" do
    @desc_md_ds.term_values(:display_name).should == ["BU3A5"]
  end
  
  it "should have the correct :ftk_id value" do
    @desc_md_ds.term_values(:ftk_id).should == ["1004"]
    # should it also have a proxy of :local_id?
  end

  it "should have the correct :filepath value" do
    @desc_md_ds.term_values(:filepath).should == ["CM006.001/NONAME [FAT12]/[root]/BU3A5"]
  end

  it "should have the correct :extent value" do
    @desc_md_ds.term_values(:extent).should == ["35654", "5 1/2 inch floppy disk"]
  end

  it "should have the correct :digital_origin term value" do
    @desc_md_ds.term_values(:digital_origin).should == ["born digital"]
  end

  it "should have the correct :filetype value" do
    @desc_md_ds.term_values(:filetype).should == ["WordPerfect 4.2"]
  end

  it "should have the correct date values" do
    @desc_md_ds.term_values(:date_created).should == ["12/6/1988"]
    @desc_md_ds.term_values(:date_last_accessed).should == ["12/10/1988"]
    @desc_md_ds.term_values(:date_last_modified).should == ["12/8/1988 6:48:48 AM (1988-12-08 14:48:48 UTC)"]
  end
  
  it "should have the correct :addl_title value" do
    @desc_md_ds.term_values(:addl_title).should == ["The Burgess Shale and the Nature of History"]
  end

  it "should have the correct :note_plain value" do
    @desc_md_ds.term_values(:note_plain).should == ["Journal Article"]
  end

end