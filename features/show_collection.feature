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
    Then pending
  
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
  
  
