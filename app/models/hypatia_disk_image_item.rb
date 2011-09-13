# a Fedora object for the Hypatia Xanadu ITEM hydra content type
class HypatiaDiskImageItem < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaItemDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaItemContentMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  has_bidirectional_relationship "part_of", :is_part_of, :has_part
  has_bidirectional_relationship "sets", :is_member_of, :has_member
end