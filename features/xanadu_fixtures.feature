Feature: Xanadu Fixtures
  As an interim step to really useful features
  I want to ensure the Xanadu fixtures loaded properly

  Scenario: View collection object
    When I am on the document page for id "hypatia:fixture_xanadu_collection" 
    Then I should see "hypatia:fixture_xanadu_collection"
    And I should see "Keith Henson. Papers relating to Project Xanadu, XOC and Eric Drexler"

  Scenario: Search for dor
    When I am on the home page
    And I fill in "q" with "dor"
#    Then I should see "5 results"

  Scenario: Search for xanadu
    When I am on the home page
    And I fill in "q" with "xanadu"
#    Then I should see "4 results"
