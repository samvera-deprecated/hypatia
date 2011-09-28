# a Fedora object for the Hypatia SET hydra content type
class HypatiaCollection < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaCollDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaCollContentMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  
  # a collection has members
  has_relationship "members", :is_member_of_collection, :inbound=>true
  # there are files such as EAD and image to be attached
  has_relationship "parts", :is_part_of, :inbound => true  
end