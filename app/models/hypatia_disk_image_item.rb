# an ActiveFedora model for a Hypatia Disk Image ITEM object
class HypatiaDiskImageItem < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaItemDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaDiskImgContentMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata

  # a disk image item is a member of a collection
  has_relationship "collections", :is_member_of_collection, :type => HypatiaCollection
  # a disk image can belong to sets  -- FIXME:  does this need to be bidirectional?
#  has_relationship "sets", :is_member_of, :type => HypatiaSet
  has_bidirectional_relationship "sets", :is_member_of, :has_member
  # a disk image item can have members (e.g.  file items)
  has_relationship "members", :is_member_of, :inbound=>true
  # there are files such as dd and image to be attached 
  has_relationship "parts", :is_part_of, :inbound => true, :type => FileAsset
end