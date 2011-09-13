Feature: FTK Item Object Show View 
  I want to ensure FTK item objects display correctly in the show view

  Scenario: FTK item object descMetadata
    When I am on the document page for id "hypatia:fixture_ftk_wp6_item"
    Then I should see "Natural History Magazine Column"

  Scenario: FTK item object technical information should include the contentMetadata Object id
    When I am on the document page for id "hypatia:fixture_ftk_wp6_item" 
    Then I should see "Content Object ID"
    And I should see "NATHIN50.WPD_52029"

  Scenario: FTK item object  contentMetadata (contained files)
    # file name, downloadable link, file size
    When I am on the document page for id "hypatia:fixture_ftk_wp6_item" 
    Then I should see "NATHIN50.WPD "

