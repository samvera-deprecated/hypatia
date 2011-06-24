require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DorIdentityMetadataDS do
  
  it "should have term :dor_object_id (because it apparently can't use :object_id?  2011-06-22)" do
    dor_id_md_ds = DorIdentityMetadataDS.from_xml(active_fedora_fixture("dor_identity_metadata.xml"))
    dor_id_md_ds.term_values(:dor_object_id).should == ["druid:tk694zs2244"]
  end
  
  it "should have a :uuid term populated from <otherId name=\"uuid\">" do
    dor_id_md_ds = DorIdentityMetadataDS.from_xml(active_fedora_fixture("dor_identity_metadata.xml"))
    dor_id_md_ds.term_values(:uuid).should == ["c097de5b-bd21-b95e-944a-769bd46f1928"]
  end
  
  it "should have a :hypatia_id term populated from <sourceId source=\"hypatia\">" do
    dor_id_md_ds = DorIdentityMetadataDS.from_xml(active_fedora_fixture("dor_identity_metadata.xml"))
    dor_id_md_ds.term_values(:hypatia_source_id).should == ["M1292_CM01"]
  end

  it "should have a :creator term that is a proxy for the :object_creator term" do
    dor_id_md_ds = DorIdentityMetadataDS.from_xml(active_fedora_fixture("dor_identity_metadata.xml"))
    dor_id_md_ds.term_values(:object_creator).should == ["DOR"]
    dor_id_md_ds.term_values(:creator).should == dor_id_md_ds.term_values(:object_creator)
  end

end