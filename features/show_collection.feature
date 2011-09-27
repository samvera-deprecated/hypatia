Feature: Collection View
  As a viewing user
  I want to ensure collection fixture objects display properly
  
  Scenario: links to members of the collection
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then I should see "In this Collection"
    And I should see a link to the show page for "hypatia:fixture_media_item"
    And I should see a link to the show page for "hypatia:fixture_ftk_file_item"
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

  Scenario: all desired descriptive metadata displays
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then I should see "Fake Collection"  # title
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

  
  Scenario: all desired technical metadata displays
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then pending
  
  Scenario: link to download the collection's EAD file
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then pending
    And I should see a link to the show page for "hypatia:fixture_file_asset_ead_for_coll"
    
  Scenario: collection image should display
    When I am on the document page for id "hypatia:fixture_coll2" 
    Then pending

  Scenario: searching for coll record -- put this in a separate searching feature
    Given pending
  
  # FIXME:  there should be a general show feature that ensures the fedora id and anything else true for all objects is used in the UI appropriately
