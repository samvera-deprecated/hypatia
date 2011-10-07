require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HydraFedoraMetadataHelper do
  include HydraFedoraMetadataHelper
  before(:all) do
    @resource = mock("fedora object")
    @resource.stubs(:get_values_from_datastream).with("simple_ds", "subject", "").returns( ["topic1","topic2"] )
  end
  it "should make a text field disabled if :disabled=>true" do
    fedora_text_field(@resource,"simple_ds","subject", :disabled=>true).should match(/disabled/)    
    fedora_text_field(@resource,"simple_ds","subject", :disabled=>false).should_not match(/disabled/)    
    fedora_text_field(@resource,"simple_ds","subject").should_not match(/disabled/)    
  end
end