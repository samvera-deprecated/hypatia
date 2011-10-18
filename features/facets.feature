Feature: Facets on Home Page and Search Results
  I want facets to display and work properly

  Scenario: home page facets
    When I am on the home page
    Then I should see "Browse Results:"
    And I should see "Repository"
  
  Scenario: search results facets
    When I am on the home page
    And I fill in "q" with "hypatia"
    And I press "Search"
    Then I should see "Filter Results:"
    And I should see "Repository"

  Scenario: i18n translations
    When I am on the home page
    Then I should not see "info:fedora/afmodel:HypatiaDiskImageItem"
    And I should see "Disk Image"
    When I follow "Disk Image" within "#facets"
    Then I should not see "info:fedora/afmodel:HypatiaDiskImageItem"
    And I should see "Disk Image"