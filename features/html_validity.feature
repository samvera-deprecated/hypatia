Feature: HTML validity
  In order to verify that the application in HTML5 valid
  I want the pages to conform to the W3C HTML5 validation
  
  Scenario: Home page (unauthenticated)
    When I am on the home page
    Then the page should be HTML5 valid
    
#  Scenario: Home page (authenticated)
#    Given I am logged in as "archivist1" 
#    When I am on the home page
#    Then the page should be HTML5 valid

  Scenario: Search Results (unauthenticated)
    Given I am on the home page
    When I fill in "q" with "dor"
    And I press "Search"
    Then the page should be HTML5 valid

#  Scenario: Search Results (authenticated)
#    Given I am logged in as "archivist1" 
#    When I am on the home page
#    And I follow "Article"
#    Then the page should be HTML5 valid

  Scenario: Xanadu item show view (unauthenticated)
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then the page should be HTML5 valid

#  Scenario: Xanadu item show view (authenticated)
#    Given I am logged in as "archivist1" 
#    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
#    Then the page should be HTML5 valid
    
# Xanadu collection view

# other collections item and sets