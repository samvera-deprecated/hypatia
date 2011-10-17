Feature: Edit Hypatia items
  In order to verify that the edit flow for Hypatia items is working correctly
  As a user
  I want to see beautiful edit screens

  Scenario: Edit forms existence
    Given I am logged in as the "archivist1" user
    When I am on the edit document page for hypatia:fixture_media_item
    Then I should see "Add Your Work"
    And the "digital_origin" field within "#digital_origin_field" should contain "Born Digital"
    
    
  Scenario: Editing Description of Ftk (File) Item Object
    Given I am logged in as the "archivist1" user
    When I am on the edit description page for hypatia:fixture_ftk_file_item
    Then the "note_plain" field within "#note_plain_field" should contain "Journal Article"
    And the "digital_origin" field within "#digital_origin_field" should contain "born digital"
    And the "extent_0" field within "#extent_field" should contain "35654"
    And the "extent_1" field within "#extent_field" should contain "Punch Cards"
    When I fill in "addl_title" with "Foo"
    And I press "Save and Continue"
    Then I should see "Foo"
    When I am on the edit files page for hypatia:fixture_ftk_file_item
    Then I should see "35654" # extent
    And I should see "Punch Cards" # extent
    When I am on the edit description page for hypatia:fixture_ftk_file_item
    When I fill in "addl_title" with "The Burgess Shale and the Nature of History"
    Then I press "Save and Finish"
    
  Scenario: Editing object
    Given I am logged in as the "archivist1" user
    When I am on the edit files page for hypatia:fixture_ftk_file_item
    Then I should see "Description"
    And I should see "WordPerfect 4.2"
    And I should see "Number of files add"
    When I am on the edit technical_info page for hypatia:fixture_ftk_file_item
    Then I should see "FileAsset Object Id"
    And I should see "WordPerfect 4.2"
    When I am on the edit permissions page for hypatia:fixture_ftk_file_item
    Then I should see "Technical Information"
    And I should see "Group Permissions"
  
  # Scenario: Saving data in objects
  #   Given I am logged in as the "archivist1" user
  #   When I am on the edit document page for hypatia:fixture_media_item
  #   And I fill in "digital_origin" with "born digital"