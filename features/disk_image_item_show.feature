Feature: Disk Image Item Show page
  As a user
  I want to see Disk Image Item object data displaying properly

  Scenario: links to parents (collections or sets) of this object
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "Member of"
    And I should see a link to the show page for "hypatia:fixture_coll2"

  Scenario: links to members (children) of this object
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "In this Collection"
    And I should see a link to the show page for "hypatia:fixture_ftk_file_item"

  