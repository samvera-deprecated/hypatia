# a Fedora object for the Hypatia Ftk ITEM hydra content type
class HypatiaFtkFile < ActiveFedora::Base
  has_relationship "member_of", :is_member_of  
end