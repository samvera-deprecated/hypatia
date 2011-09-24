require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaCollDescMetadataDS do
  before(:all) do
    @desc_md_ds = HypatiaCollDescMetadataDS.from_xml(active_fedora_fixture("coll_desc_metadata.xml"))
  end
    
  it "should correctly assign terms based on a combination of element name and attribute value" do
    @desc_md_ds.term_values(:local_id).should == ["M666"]
  end
    
  it "should allow multiple values for a term" do
    @desc_md_ds.term_values(:extent).length.should == 2
    @desc_md_ds.term_values(:extent).should == ["564.5 Linear feet", "(34 cartons, 3 flat boxes, 2 map folders, 7 boxes)"]
  end
  
    
  it "should have the correct :title term value" do
    @desc_md_ds.term_values(:title).should == ["Fake Collection"]
    @desc_md_ds.term_values(:title_info, :title).should == ["Fake Collection"]
  end
  
# FIXME:  want a :creator term and a :repository term
  it "should have the correct :personal_name term value" do
    @desc_md_ds.term_values(:personal_name).should == ["Creator, Name of"]
  end

  it "should have the correct :corporate_name term value" do
    @desc_md_ds.term_values(:institution_name).should == ["Corporate Name"]
  end
  
  it "should have the correct :local_id term value" do
    @desc_md_ds.term_values(:local_id).should == ["M666"]
  end
  
  it "should have the correct :create_date term value" do
    @desc_md_ds.term_values(:create_date).should == ["1977-1997"]
  end
  
  it "should have the correct :located_in term value" do
    @desc_md_ds.term_values(:located_in).should == ["My collection - Born-Digital Materials - Computer disks / tapes - Carton 11"]
  end
  
  it "should have the correct :lang_code term value" do
    @desc_md_ds.term_values(:lang_code).should == ["eng"]
  end

end