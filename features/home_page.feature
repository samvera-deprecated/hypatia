Feature: Homepage
  As a user
  In order to begin using the application
  I want to visit the homepage

  Scenario: Visiting home page
    When I am on the home page
    Then I should not see "override"
    And I should see "Hypatia"
    And I should see "Search"
