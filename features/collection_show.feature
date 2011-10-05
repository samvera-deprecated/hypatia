Feature: Collection Show page
  As a user
  I want to see collection object data displaying properly
  
  Scenario: links to members of the collection
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then I should see "In this Collection"
    And I should see a link to the show page for "hypatia:fixture_media_item" with label "CM058"
    And I should see a link to the show page for "hypatia:fixture_ftk_file_item" with label "BU3A5"
    When I am on the document page for id "hypatia:fixture_coll"
    Then I should see "In this Collection"
    And I should see a link to the show page for "hypatia:fixture_intermed1"
    And I should see a link to the show page for "hypatia:fixture_intermed3"
  
  Scenario: no links to file assets belonging to other objects
    When I am on the document page for id "hypatia:fixture_coll2" 
    And I should not see a link to the show page for "hypatia:fixture_file_asset_dd_for_media_item"
    And I should not see a link to the show page for "hypatia:fixture_file_asset_image1_for_media_item"
    And I should not see a link to the show page for "hypatia:fixture_file_asset_image2_for_media_item"
    And I should not see a link to the show page for "hypatia:fixture_file_asset_for_ftk_file_item"
    
  Scenario: no links to sets or objects that are not direct members of the collection
    When I am on the document page for id "hypatia:fixture_coll"
    Then I should see "In this Collection"
    And I should not see a link to the show page for "hypatia:fixture_intermed2"
    And I should not see a link to the show page for "hypatia:fixture_item1"
    And I should not see a link to the show page for "hypatia:fixture_item2"
    And I should not see a link to the show page for "hypatia:fixture_item3"

  Scenario: all desired Descriptiion metadata displays
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then I should see "Fake Collection"  # title, display_name
    And I should see "1977-1997" # create date
    And I should see "My collection - Born-Digital Materials - Computer disks / tapes - Carton 11" # located in
    And I should see "eng" # language
    And I should see "564.5 Linear feet" # extent
    And I should see "(34 cartons, 3 flat boxes, 2 map folders, 7 boxes)" # extent
    And I should see "Videorecordings" # genre
    And I should see "this is text inside a plain abstract element" # abstract
    And I should see "this is text in an abstract element with a \"Preferred Citation\" displayLabel." # citation
    And I should see "this is text in an abstract element with a \"Description of the Papers\" displayLabel."  # description
    And I should see "this is text in an abstract element with a \"Scope and Contents\" displayLabel."  # scope and contents
    And I should see "plain topic1"
    And I should see "plain topic2"
    And I should see "topic lcsh authority1"
    And I should see "topic lcsh authority2"
    And I should see "topic ingest authority"
  
  Scenario: all desired Creator metadata displays
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then I should see "Creator, Name of" # creator
    And I should see "this is text in an abstract element with a \"Biography\" displayLabel." # biography
  
  Scenario: all desired Repository metadata displays
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then I should see "Corporate Name" # repository
    And I should see "M666" # local_id
    And I should see "this is text with html elements in an abstract element with an \"Acquisition Information\" displayLabel" # acquisition info
    And I should see "pub rights text"  # accessCondition with "PublicationRights" displayLabel
    And I should see "ownership and copyright text" # accessCondition with "Ownership & Copyright" displayLabel
    And I should see "access to collection text" # accessCondition  with "Access to Collection" displayLabel
    And I should see "this is text in an abstract element with a \"Provenance\" displayLabel." # provenance

  Scenario: all desired Technical metadata displays
    When I am on the document page for id "hypatia:fixture_coll2"
    Then I should see "EAD File" # title of subsection
    And I should see "coll_ead.xml" # ead_filename
    And I should see "hypatia:fixture_file_asset_ead_for_coll" # ead_fedora_pid 
    And I should see "DS1" # ead_ds_id
    And I should see "47570" # ead_size
    And I should see "text/xml" # ead_mimetype
    And I should see "856d7eae922f80e68c954d2e3521f74a" # ead_md5
    And I should see "1a79a23e7827ee62370850def76afdeccf3fbadb" # ead_sha1
    And I should see "Image for Collection" # title of subsection
    And I should see "fixture_coll_image.jpg" # image_filename
    And I should see "hypatia:fixture_file_asset_image_for_coll" # image_fedora_pid 
    And I should see "DS1" # image_ds_id
    And I should see "302080" # image_size
    And I should see "image/jpeg" # image_mimetype
    And I should see "856d7eae922f80e68c954d2e3521f74ab" # image_md5
    And I should see "1a79a23e7827ee62370850def76afdeccf3fbadbc" # image_sha1

  Scenario: link to Download the collection's EAD file
    When I am on the document page for id "hypatia:fixture_coll2"
    Then I should see "coll_ead.xml" # ead_filename
    And I should see "47570" # ead_size
    And I should see "text/xml" # ead_mimetype
    And I should see a link to datastream "DS1" in FileAsset object "hypatia:fixture_file_asset_ead_for_coll"

# TODO this needs more work
  Scenario: collection image should display
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then I should see "fixture_coll_image.jpg"  # alt text?
    Then I should not see a link to datastream "DS1" in FileAsset object "hypatia:fixture_file_asset_image_for_coll"

#  Scenario: searching for coll record -- put this in a separate searching feature?
#    Given pending
  
