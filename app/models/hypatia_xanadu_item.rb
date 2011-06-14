# a Fedora object for the Hypatia Xanadu ITEM hydra content type
class HypatiaXanaduItem < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaItemDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaItemContentMetadataDS
  has_metadata :name => "identityMetadata", :type=> DorIdentityMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
end