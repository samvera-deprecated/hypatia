Feature: Hypatia disk image item edit
  In order to validate that the hypatia disk image items are editable
  As a user
  I want to be able to edit the hypatia disk image item objects
  
  Scenario: Description Edit Page
    Given I am logged in as the "archivist1" user
    When I am on the edit description page for hypatia:fixture_media_item
    Then I should see "Description"
    And I should see "Disk Image"
    And the "extent" field within "#extent_field" should contain "3.5 inch Floppy Disk"
    Then I should see "Repository"
    And the "local_id" field within "#local_id_field" should contain "M1437"
    
  Scenario: Editing Description
    Given I am logged in as the "archivist1" user
    When I am on the edit description page for hypatia:fixture_media_item
    And I fill in "digital_origin" with "Not Born Digital"
    When I press "Save and Continue"
    Then I should see "Not Born Digital"
    When I am on the edit description page for hypatia:fixture_media_item
    Then the "digital_origin" field within "#digital_origin_field" should contain "Not Born Digital"
    Then I fill in "digital_origin" with "born digital"
    Then I press "Save and Finish"
  
  Scenario: File Edit
    Given I am logged in as the "archivist1" user
    When I am on the edit files page for hypatia:fixture_media_item
    Then I should see "Files"
    And I should see "CM058.dd"
    And I should see "3.5 inch Floppy Disk"
    
  Scenario: Technical Info Edit Page
    Given I am logged in as the "archivist1" user
    When I am on the edit technical_info page for hypatia:fixture_media_item
    Then I should see "3.5 inch Floppy Disk"
    And I should see "CM058.dd"
    Then I should see "Technical Information"
    And I should see "Disk Image File"
    And the "dd_filename" field within "#dd_filename_field" should contain "CM058.dd"
    Then I should see "Image of Disk - Front"
    And the "image_front_filename" field within "#image_front_filename_field" should contain "fixture_media_item_front.jpg"
    Then I should see "Image of Disk - Back"
    And the "image_back_filename" field within "#image_back_filename_field" should contain "fixture_media_item_back.jpg"