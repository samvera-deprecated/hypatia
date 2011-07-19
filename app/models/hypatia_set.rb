# a Fedora object for the Hypatia SET hydra content type
class HypatiaSet < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaSetDescMetadataDS
  has_metadata :name => "identityMetadata", :type=> DorIdentityMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  
  # note that sets could have other sets as members ...
  has_relationship "members", :is_member_of, :inbound=>true, :type=>HypatiaXanaduItem
end