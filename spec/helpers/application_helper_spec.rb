require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  include ApplicationHelper
  
  describe "Overall UI methods" do
    it "should get the local application name" do
      application_name.should == "Hypatia"
    end
  end
  
  describe "Image Helpers" do
    it "should return an empty string when there is no filename (e.g. no image)" do
      helper.expects(:get_values_from_datastream).returns("")
      helper.get_image_tag_from_content_md({:id=>"fake"},:reference,{}).should == ""
    end
  end
  
end