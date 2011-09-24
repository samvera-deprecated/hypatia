# a Fedora object for the Hypatia SET hydra content type
class HypatiaCollection < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaCollDescMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  
  has_relationship "members", :is_member_of, :inbound=>true
  # there are files such as EAD and image to be attached
  has_relationship "parts", :is_part_of, :inbound => true  
end