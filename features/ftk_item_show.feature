Feature: FTK Item Object Show View 
  As a user
  I want to see FTK Item object data displaying properly

  Scenario: links to parents (collections or sets) of this object
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
    Then I should see "Member of"
    And I should see a link to the show page for "hypatia:fixture_coll2" with label "Fake Collection"
    And I should see a link to the show page for "hypatia:fixture_media_item" with label "CM058"

  Scenario: all desired Description metadata displays
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
    Then I should see "BU3A5"  # filename, display_name
    And I should see "1004"  # ftk_id
    And I should see "CM006.001/NONAME [FAT12]/[root]/BU3A5"  # filepath
    And I should see "35654" # extent
    And I should see "WordPerfect 4.2" # filetype
    And I should see "12/6/1988" # date_created
    And I should see "12/10/1988" # date_last_accessed
    And I should see "12/8/1988 6:48:48 AM (1988-12-08 14:48:48 UTC)" # date_last_modified
    And I should see "The Burgess Shale and the Nature of History" # addl_title


  Scenario: FTK item object technical information should include the contentMetadata Object id
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
#    Then I should see "Content Object ID"
#    And I should see "NATHIN50.WPD_52029"

  Scenario: FTK item object  contentMetadata (contained files)
    # file name, downloadable link, file size
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
#    Then I should see "BURCH1.html1"

