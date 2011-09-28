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
    When I am on the edit files page for hypatia:fixture_xanadu_drive1
    Then I should see "Description"
    And I should see "born digital"
    And I should see "Number of files add"
    When I am on the edit technical_info page for hypatia:fixture_xanadu_drive1
    Then I should see "Content Object ID"
    And I should see "druid:tk694zs2244"
    When I am on the edit permissions page for hypatia:fixture_xanadu_drive1
    Then I should see "Technical info"
    And I should see "Group Permissions"
  