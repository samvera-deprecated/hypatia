Feature: File downloading via links in views
  In order to be able to get actual files
  As a user
  I want file download links to work
  
  Scenario: FTK file downloads work from ftk item
    Given context
    When I am on the document page for id "hypatia:fixture_ftk_item_factory"
    Then I should see a link to "fixture_ftk_file_factory/downloads?download_id=DS1"

  
