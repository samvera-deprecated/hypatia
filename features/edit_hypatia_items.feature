Feature: Edit Hypatia items
  In order to verify that the edit flow for Hypatia items is working correctly
  As a user
  I want to see beautiful edit screens

  Scenario: Edit forms existence
    Given I am logged in as the "archivist1" user
    When I am on the edit document page for hypatia:fixture_xanadu_drive1
    Then I should see "Add Your Work"
    And the "digital_origin" field within "#digital_origin_field" should contain "born digital"
    
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
  #   When I am on the edit document page for hypatia:fixture_xanadu_drive1
  #   And I fill in "digital_origin" with "born digital"