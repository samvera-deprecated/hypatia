Feature: Hypatia collection edit
  In order to validate that the hypatia collections are editable
  As a user
  I want to be able to edit the hypatia collection objects
  
  Scenario: Description Edit Page
    Given I am logged in as the "archivist1" user
    When I am on the edit description page for hypatia:fixture_coll2
    Then I should see "Description"
    And I should see "Collection"
    And the "extent_0" field within "#extent_field" should contain "564.5 Linear feet"
    Then I should see "Creator"
    And the "creator" field within "#creator_field" should contain "Creator, Name of"
    Then I should see "Repository"
    And the "pub_rights" field within "#pub_rights_field" should contain "pub rights text"
    
  Scenario: Editing Description
    Given I am logged in as the "archivist1" user
    When I am on the edit description page for hypatia:fixture_coll2
    And I fill in "genre" with "Videotapes"
    When I press "Save and Continue"
    Then I should see "Videotapes"
    When I am on the edit description page for hypatia:fixture_coll2
    Then the "genre" field within "#genre_field" should contain "Videotapes"
    Then I fill in "genre" with "Videorecordings"
    Then I press "Save and Finish"
  
  Scenario: File Edit
    Given I am logged in as the "archivist1" user
    When I am on the edit files page for hypatia:fixture_coll2
    Then I should see "Files"
    And I should see "fixture_coll_image.jpg"
    And I should see "564.5 Linear feet"
    
  Scenario: Technical Info Edit Page
    Given I am logged in as the "archivist1" user
    When I am on the edit technical_info page for hypatia:fixture_coll2
    Then I should see "564.5 Linear feet"
    And I should see "fixture_coll_image.jpg"
    Then I should see "Technical Information"
    And I should see "EAD File"
    And the "ead_filename" field within "#ead_filename_field" should contain "coll_ead.xml"
    Then I should see "Image for Collection"
    And the "image_filename" field within "#image_filename_field" should contain "fixture_coll_image.jpg"