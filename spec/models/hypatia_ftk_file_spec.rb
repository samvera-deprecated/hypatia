require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "active_fedora"

describe HypatiaFtkFile do
  
  before(:all) do
    # Fedora::Repository.stubs(:instance).returns(stub('ftk_file_stub').as_null_object)
    @hypatia_ftk_item = HypatiaFtkFile.new
  end
  
  after(:all) do
    @hypatia_ftk_item.delete
  end
  
  it "should be a kind of ActiveFedora::Base" do
    @hypatia_ftk_item.should be_kind_of(ActiveFedora::Base)
  end
  
  it "should have a member_of relationship with FtkItem" do
    @hypatia_ftk_item.should respond_to(:member_of)
  end
  
  it "should be a member of an ftk item" do
    i = HypatiaFtkItem.new
    i.save
    f = HypatiaFtkFile.new
    f.save
    f.add_relationship(:is_member_of,i)
    f.save
    i.members.first.pid.should eql(f.pid)
    i.delete
    f.delete
  end
  
  it "should have a blob" do
    filepath = '/../fixtures/ftk/files/foofile.txt'
    file = File.new(File.dirname(__FILE__) + filepath)
    file_ds = ActiveFedora::Datastream.new(:dsID => "content", :dsLabel => 'File Payload', :controlGroup => 'M', :blob => file)
    @hypatia_ftk_item.add_datastream(file_ds)
    @hypatia_ftk_item.save
    @hypatia_ftk_item.datastreams['content'].blob.should be_kind_of(File)
        

    # file = File.new('spec/fixtures/minivan.jpg')
    # => #<File:spec/fixtures/minivan.jpg>
    # file_ds = ActiveFedora::Datastream.new(:dsID => "minivan", :dsLabel => 'hello', :controlGroup => 'M', :blob => file)
    # => ...
    # oh.add_datastream(file_ds)
    # => "minivan" 
    # oh.save
    # => true
  end

  # it "should have a contentMetadata datastream of type HypatiaItemContentMetadataDS" do
  #   @hypatia_ftk_item.datastreams.should have_key("contentMetadata")
  #   @hypatia_ftk_item.datastreams["contentMetadata"].should be_instance_of(HypatiaItemContentMetadataDS)
  # end

  # it "should have a identityMetadata datastream of type DorIdentityMetadataDS" do
  #   @hypatia_ftk_item.datastreams.should have_key("identityMetadata")
  #   @hypatia_ftk_item.datastreams["identityMetadata"].should be_instance_of(DorIdentityMetadataDS)
  # end

  # it "should have a rightsMetadata datastream of type Hydra::RightsMetadata" do
  #   @hypatia_ftk_item.datastreams.should have_key("rightsMetadata")
  #   @hypatia_ftk_item.datastreams["rightsMetadata"].should be_instance_of(Hydra::RightsMetadata)
  # end
    
end