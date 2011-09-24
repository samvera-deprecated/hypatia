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
  it "should have the (FIXME: approximately) correct :personal_name term value" do
    value = @desc_md_ds.term_values(:person).first.gsub(/\s+/," ").strip
    value.start_with?("Creator, Name of").should be_true
#    @desc_md_ds.term_values(:person).should == ["Creator, Name of"]
  end

  it "should have the (FIXME: approximately) correct :corporate_name term value" do
    value = @desc_md_ds.term_values(:institution).first.gsub(/\s+/," ").strip
    value.start_with?("Corporate Name").should be_true
#    @desc_md_ds.term_values(:institution).should == ["Corporate Name"]
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

  it "should have the correct extent values" do
    @desc_md_ds.term_values(:extent).length.should == 2
    @desc_md_ds.term_values(:extent).should == ["564.5 Linear feet", "(34 cartons, 3 flat boxes, 2 map folders, 7 boxes)"]
  end

  it "should have the correct :genre term value" do
    @desc_md_ds.term_values(:genre).should == ["Videorecordings"]
  end
  
  it "should have the correct plain :abstract term value" do
    @desc_md_ds.term_values(:abstract).should == ["this is text inside a plain abstract element"]
  end
  it "should have the correct :biography term value" do
    @desc_md_ds.term_values(:biography).should == ['this is text in an abstract element with a "Biography" displayLabel.']
  end
  it "should have the correct :acquisition_info term value" do
    value = @desc_md_ds.term_values(:acquisition_info).first.gsub(/\s+/," ").strip
    value.start_with?('this is text with html elements in an abstract element with an "Acquisition Information" displayLabel').should be_true
  end
  it "should have the correct :provenance term value" do
    @desc_md_ds.term_values(:provenance).should == ['this is text in an abstract element with a "Provenance" displayLabel.']
  end
# would like to have a way to populate :citation with more than one displayLabel attribute value  
  it "should have correct :citation term values" do
    @desc_md_ds.term_values(:citation).should == ["this is text in an abstract element with a \"Preferred Citation\" displayLabel."]
  end
  it "should have the correct :description term value" do
    @desc_md_ds.term_values(:description).should == ["this is text in an abstract element with a \"Description of the Papers\" displayLabel."]
  end
# would like to have a way to populate :scope_and_content with more than one displayLabel attribute value  
  it "should have correct :scope_and_contents term values" do
    @desc_md_ds.term_values(:scope_and_content).should == ["this is text in an abstract element with a \"Scope and Contents\" displayLabel."]
  end
  
  it "should have correct :topic_plain values" do
    @desc_md_ds.term_values(:topic_plain).length.should == 2
    @desc_md_ds.term_values(:topic_plain).should == ["plain topic1", "plain topic2"]
  end
  it "should have correct :topic_lcsh values" do
    @desc_md_ds.term_values(:topic_lcsh).length.should == 2
    @desc_md_ds.term_values(:topic_lcsh).should == ["topic lcsh authority1", "topic lcsh authority2"]
  end
  it "should have the correct :topic_ingest value" do
    @desc_md_ds.term_values(:topic_ingest).should == ["topic ingest authority"]
  end
  it "should have the correct :topic values" do
    @desc_md_ds.term_values(:topic).length.should == 5
    @desc_md_ds.term_values(:topic).should == ["topic lcsh authority1", "topic lcsh authority2", "topic ingest authority", "plain topic1", "plain topic2"]
  end
  
  


end