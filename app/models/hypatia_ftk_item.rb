# a Fedora object for the Hypatia Ftk ITEM hydra content type
class HypatiaFtkItem < ActiveFedora::Base
  # adds helpful methods for basic hydra objects, like permissions manipulations
  include Hydra::ModelMethods
  
  has_metadata :name => "descMetadata", :type=> HypatiaFTKItemDescMetadataDS
  has_metadata :name => "contentMetadata", :type=> HypatiaFTKItemContentMetadataDS
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata
  
  # an ftk item can be a direct member of a collection
  has_relationship "collections", :is_member_of_collection, :type => HypatiaCollection
  # an ftk item can belong to sets
  has_relationship "sets", :is_member_of
  # there are files to be attached
  has_relationship "parts", :is_part_of, :inbound => true, :type => FileAsset
end