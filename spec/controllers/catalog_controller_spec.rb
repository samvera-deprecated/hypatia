require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CatalogController do
  
  describe "updating relationships" do
    it "should add is_member_of_collection relationships when adding to a collection" do
      collection = HypatiaCollection.new
      set = HypatiaSet.new
      controller.expects(:load_fedora_doc_from_id).with("collection:record").returns(collection)
      controller.expects(:load_fedora_doc_from_id).with("set:1234").returns(set)
      set.expects(:add_relationship).with(:is_member_of_collection,"collection:record")
      set.expects(:save).returns(set)
      get :update_members, :id=>"collection:record", :child_ids => ["set:1234"]
    end
    it "should add is_member_of relationships when adding to anything else" do
      set = HypatiaSet.new
      item = HypatiaFtkItem.new
      controller.expects(:load_fedora_doc_from_id).with("set:record").returns(set)
      controller.expects(:load_fedora_doc_from_id).with("item:1234").returns(item)
      item.expects(:add_relationship).with(:is_member_of,"set:record")
      item.expects(:save).returns(item)
      get :update_members, :id=>"set:record", :child_ids => ["item:1234"]
    end
    it "should remove relationships properly" do
      collection = HypatiaCollection.new
      set = HypatiaSet.new
      controller.expects(:load_fedora_doc_from_id).with("collection:record").returns(collection)
      controller.expects(:load_fedora_doc_from_id).with("set:4321").returns(set)
      collection.expects(:members_ids).at_least(1).returns(["set:1234","set:4321"])
      set.expects(:remove_relationship).with(:is_member_of_collection,"collection:record")
      set.expects(:save).returns(set)
      get :update_members, :id=>"collection:record", :child_ids => ["set:1234"]
    end
    it "should handle removing ALL relationships properly" do
      collection = HypatiaCollection.new
      set = HypatiaSet.new
      controller.expects(:load_fedora_doc_from_id).with("collection:record").returns(collection)
      controller.expects(:load_fedora_doc_from_id).with("set:4321").returns(set)
      collection.expects(:members_ids).at_least(1).returns(["set:4321"])
      set.expects(:remove_relationship).with(:is_member_of_collection,"collection:record")
      set.expects(:save).returns(set)
      get :update_members, :id=>"collection:record"
    end
  end
end