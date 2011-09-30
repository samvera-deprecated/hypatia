# a Fedora object for the Hypatia SET hydra content type
class HypatiaSet < ActiveFedora::Base
  has_metadata :name => "descMetadata", :type=> HypatiaSetDescMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata

  # a set is a member of a collection
  has_relationship "collections", :is_member_of_collection, :type => HypatiaCollection
  # a set has members
  has_relationship "members", :is_member_of, :inbound=>true
  # a set can belong to other sets
  has_relationship "sets", :is_member_of, :type => HypatiaSet
end