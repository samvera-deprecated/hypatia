Feature: Set edit
  In order to properly edit the set objects
  As a user
  I want to see an edit form and be able to edit the objects
  
  Scenario: Editing Description
    Given I am logged in as the "archivist1" user
    When I am on the edit description page for hypatia:fixture_intermed1
    Then the "note_0" field within "#note_field" should contain "note1"
    When I fill in "note_0" with "note3" 
    And I press "Save and Continue"
    Then I should see "note3"
    And I should not see "note1"
    When I am on the edit description page for hypatia:fixture_intermed1
    Then the "note_0" field within "#note_field" should contain "note3"
    And I fill in "note_0" with "note1"
    And I press "Save and Continue"