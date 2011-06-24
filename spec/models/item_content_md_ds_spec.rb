require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HypatiaItemContentMetadataDS do
  
  it "should be able to distinguish between content level and resource level object ids" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata.xml"))
    content_md_ds.term_values(:content_oid).should == ["druid:tk694zs2244"]
    content_md_ds.term_values(:resource_oid).should == ["druid:mc116fw4648", "druid:xg062my4398", "druid:nb727vy7154", "druid:nd615pr9748", "druid:ct102pd5508"]
  end
  
  it "should have term values from resource element attributes" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata.xml"))
    content_md_ds.term_values(:resource_type).should == ["disk-image", "photo", "photo", "analysis", "analysis"]
    content_md_ds.term_values(:resource_id).should == ["disk-image", "photo-1", "photo-2", "analysis-text", "analysis-contents"]
    content_md_ds.term_values(:resource_oid).should == ["druid:mc116fw4648", "druid:xg062my4398", "druid:nb727vy7154", "druid:nd615pr9748", "druid:ct102pd5508"]
  end
  
  it "should have term values from file element attributes" do
    content_md_ds = HypatiaItemContentMetadataDS.from_xml(active_fedora_fixture("item_content_metadata.xml"))
    content_md_ds.term_values(:file_id).should == ["CM01.dd", "CM01_01.JPG", "CM01_02.JPG", "CM01.txt", "CM01.csv"]
    content_md_ds.term_values(:format).should == ["BINARY", "JPEG", "JPEG", "TEXT", "CSV"]
    content_md_ds.term_values(:file_format).should == content_md_ds.term_values(:format)
    content_md_ds.term_values(:mimetype).should == ["application/octet-stream", "image/jpg", "image/jpg", "text/plain", "text/csv"]
    content_md_ds.term_values(:size).should == ["1408", "3187819", "3452696", "1250", "10750"]
    content_md_ds.term_values(:url).should == ["http://stacks.stanford.edu/file/druid:mc116fw4648/CM01.dd",
        "http://stacks.stanford.edu/file/druid:xg062my4398/CM01_1.JPG",
         "http://stacks.stanford.edu/file/druid:nb727vy7154/CM01_2.JPG",
          "http://stacks.stanford.edu/file/druid:nd615pr9748/CM01.txt",
           "http://stacks.stanford.edu/file/druid:ct102pd5508/CM01.csv"]
  end

end