require "hydra"
# The following lines determine which user attributes your hydrangea app will use
# This configuration allows you to use the out of the box ActiveRecord associations between users and user_attributes
# It also allows you to specify your own user attributes
# The easiest way to override these methods would be to create your own module to include in User
# For example you could create a module for your local LDAP instance called MyLocalLDAPUserAttributes:
#   User.send(:include, MyLocalLDAPAttributes)
# As long as your module includes methods for full_name, affiliation, and photo the personalization_helper should function correctly
#
# NOTE: For your development environment, also specify the module in lib/user_attributes_loader.rb
User.send(:include, Hydra::GenericUserAttributes)
# 

if Hydra.respond_to?(:configure)
  Hydra.configure(:shared) do |config|
  
    config[:file_asset_types] = {
      :default => FileAsset, 
      :extension_mappings => {
        AudioAsset => [".wav", ".mp3", ".aiff"] ,
        VideoAsset => [".mov", ".flv", ".mp4", ".m4v"] ,
        ImageAsset => [".jpeg", ".jpg", ".gif", ".png"] 
      }
    }
    config[:submission_workflow] = {
        :hypatia_items =>     [{:name => "description",    :edit_partial => "hypatia_items/description_form", :show_partial => "hypatia_items/show_description"},
                               {:name => "files",          :edit_partial => "file_assets/file_assets_form",   :show_partial => "shared/show_files"},
                               {:name => "technical_info", :edit_partial => "hypatia_items/tech_info_form",   :show_partial => "shared/show_technical"},
                               {:name => "permissions",    :edit_partial => "permissions/permissions_form",   :show_partial => "shared/show_permissions"}
                              ],
        # BEGIN real Hypatia models
        :hypatia_collections        => [{:name => "description",     :edit_partial => "hypatia_collections/description_form", :show_partial => "hypatia_collections/show_description"},
                                        {:name => "files",           :edit_partial => "file_assets/file_assets_form",         :show_partial => "hypatia_collections/show_files"},
                                        {:name => "technical_info",  :edit_partial => "hypatia_collections/technical_form",   :show_partial => "hypatia_collections/show_technical"},
                                        {:name => "permissions",     :edit_partial => "permissions/permissions_form",         :show_partial => "shared/show_permissions"}
                                       ],        
        :hypatia_ftk_items          => [{:name => "description",     :edit_partial => "hypatia_ftk_items/description_form",  :show_partial => "hypatia_ftk_items/show_description"},
                                        {:name => "files",           :edit_partial => "file_assets/file_assets_form",        :show_partial => "hypatia_ftk_items/show_files"},
                                        {:name => "technical_info",  :edit_partial => "hypatia_ftk_items/tech_info_form",    :show_partial => "hypatia_ftk_items/show_technical"},
                                        {:name => "permissions",     :edit_partial => "permissions/permissions_form",        :show_partial => "shared/show_permissions"}
                                      ],
        :hypatia_disk_image_items   => [{:name => "description",     :edit_partial => "hypatia_disk_image_items/description_form", :show_partial => "hypatia_disk_image_items/show_description"},
                                        {:name => "files",           :edit_partial => "file_assets/file_assets_form",              :show_partial => "hypatia_disk_image_items/show_files"},
                                        {:name => "technical_info",  :edit_partial => "hypatia_disk_image_items/technical_form",   :show_partial => "hypatia_disk_image_items/show_technical"},
                                        {:name => "permissions",     :edit_partial => "permissions/permissions_form",              :show_partial => "shared/show_permissions"}
                                       ],
        # END real Hypatia models
        :hypatia_sets =>      [{:name => "description",     :edit_partial => "hypatia_sets/description_form",       :show_partial => "hypatia_sets/show_description"},
                               #{:name => "technical_info",  :edit_partial => "hypatia_sets/tech_info_form",         :show_partial => "shared/show_technical"},
                               {:name => "permissions",     :edit_partial => "permissions/permissions_form",        :show_partial => "shared/show_permissions"}
                              ]
        # We don't have display views for this yet.
        # :disk_image_item =>   [{:name => "description",     :edit_partial => "hypatia_ftk_items/description_form",  :show_partial => "hypatia_ftk_items/show_description"}
        #                       ]
      }
  end
end