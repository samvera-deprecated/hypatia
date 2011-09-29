Feature: Show hypatia items
  In order to verify that Hypatia Items are being displayed correctly
  As a user
  I want to see spectacular data
  
  Scenario: Description info
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then I should see "Description"
    And I should see "Digital Origin"
    And I should see "born digital"
    
  Scenario: Technical info
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then I should see "Technical info"
    And I should see "Content Object ID"
    And I should see "druid:tk694zs2244"
    
  Scenario: Files
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then I should see "Files"
    And I should see "CM01.dd"
    
  Scenario: Permissions
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then I should not see "Permissions"
    Given I am logged in as the "archivist1" user
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then I should see "Permissions"
    And I should see "Discover Access"
