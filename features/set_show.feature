Feature: Set Object Show View 
  As a user
  I want to see Set object data displaying properly

  Scenario: links to parents (collections or sets) of this object
    When I am on the document page for id "hypatia:fixture_intermed1" 
    Then I should see "Member of"
    And I should see a link to the show page for "hypatia:fixture_coll" with label "Collection"
    When I am on the document page for id "hypatia:fixture_intermed2" 
    Then I should see "Member of"
#    And I should see a link to the show page for "hypatia:fixture_coll" with label "Collection"
    And I should see a link to the show page for "hypatia:fixture_intermed1" with label "Intermediate Set 1"
    When I am on the document page for id "hypatia:fixture_intermed3" 
    Then I should see "Member of"
    And I should see a link to the show page for "hypatia:fixture_coll" with label "Collection"

  Scenario: links to children (sets or items) of this object
    When I am on the document page for id "hypatia:fixture_intermed1" 
    Then I should see "In this Collection"
    And I should see a link to the show page for "hypatia:fixture_intermed2" with label "Intermediate Set 2"
    And I should not see a link to the show page for "hypatia:fixture_item1" with label "item 1"
    And I should not see a link to the show page for "hypatia:fixture_item2" with label "item 2"
    And I should not see a link to the show page for "hypatia:fixture_item3" with label "item3.txt"
    When I am on the document page for id "hypatia:fixture_intermed2" 
    Then I should see "In this Collection"
    And I should see a link to the show page for "hypatia:fixture_item1" with label "item 1"
    And I should see a link to the show page for "hypatia:fixture_item2" with label "item 2"
    And I should see a link to the show page for "hypatia:fixture_item3" with label "item3.txt"
    When I am on the document page for id "hypatia:fixture_intermed3" 
    Then I should see "In this Collection"
    And I should not see a link to the show page for "hypatia:fixture_item1" with label "item 1"
    And I should see a link to the show page for "hypatia:fixture_item2" with label "item 2"
    And I should see a link to the show page for "hypatia:fixture_item3" with label "item3.txt"
  
  Scenario: all desired Description metadata displays
    When I am on the document page for id "hypatia:fixture_intermed1"
    Then I should see "Intermediate Set 1"  # title, display_name
    And I should see "This is a hypatia set object containing intermed2 set object, and is a member of fixture_coll object." # scope_and_content
    And I should see "circa 1977-1997" # date_created
    And I should see "extent1" # extent
    And I should see "extent2" # extent
    And I should see "note1" # note
    And I should see "note2" # note
    And I should see "local id"  # local_id

