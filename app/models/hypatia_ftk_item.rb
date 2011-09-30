# a Fedora object for the Hypatia Ftk ITEM hydra content type
class HypatiaFtkItem < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaItemDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaItemContentMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  has_relationship "sets", :is_member_of, :type => HypatiaSet
  has_relationship "collections", :is_member_of_collection, :type => HypatiaCollection
  has_relationship "parts", :is_part_of, :inbound => true  
end