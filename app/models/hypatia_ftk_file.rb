# a Fedora object for the Hypatia Ftk ITEM hydra content type
class HypatiaFtkFile < ActiveFedora::Base
  # has_metadata :name => "descMetadata", :type=> HypatiaItemDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaItemContentMetadataDS
  # has_metadata :name => "identityMetadata", :type=> DorIdentityMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  has_relationship "member_of", :is_member_of, :type => HypatiaFtkItem
  
  # has_relationship "sets", :is_member_of, :type => HypatiaSet
end