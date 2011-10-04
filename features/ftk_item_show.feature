Feature: FTK Item Object Show View 
  I want to ensure FTK item objects display correctly in the show view

# FIXME:  just about to work on this  2011-10-03 Naomi
  Scenario: FTK item object descMetadata
    When I am on the document page for id "hypatia:fixture_ftk_file_item"
#    Then I should see "BU3A5"

  Scenario: FTK item object technical information should include the contentMetadata Object id
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
#    Then I should see "Content Object ID"
#    And I should see "NATHIN50.WPD_52029"

  Scenario: FTK item object  contentMetadata (contained files)
    # file name, downloadable link, file size
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
#    Then I should see "BURCH1.html1"

