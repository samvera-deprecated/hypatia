Feature: Facets on Home Page and Search Results
  I want facets to display and work properly

  Scenario: home page facets
    When I am on the home page
    Then I should see "Browse Results:"
    And I should see "Format"
  
  Scenario: search results facets
    When I am on the home page
    And I fill in "q" with "dor"
    And I press "Search"
    Then I should see "Filter Results:"
    And I should see "Format"
