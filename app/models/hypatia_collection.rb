# a Fedora object for the Hypatia SET hydra content type
class HypatiaCollection < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaSetDescMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  
  has_relationship "members", :is_member_of, :inbound=>true
  has_relationship "sets", :is_member_of, :type => HypatiaSet
end