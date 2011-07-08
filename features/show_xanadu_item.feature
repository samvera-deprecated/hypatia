Feature: Xanadu Item Object Show View Fixtures
  I want to ensure Xanadu item objects display correctly in the show view

  Scenario: Xanadu item object descMetadata
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then I should see "CM01"
    And I should see "1.0 computer media"
    And I should see "hard drive"
    And I should see "born digital"
    And I should see "Born-Digital Materials - Carton 11 - Computer disks / tapes"
    And I should see "The capacity of CM01 is"

  Scenario: Xanadu item object technical information (from Fedora, not EAD)
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    # repository object ID
    Then I should see "hypatia:fixture_xanadu_drive1"
    # identityMetadata
    And I should see "DOR"
    And I should see "item"
    And I should see "druid:tk694zs2244"
    And I should see "Label"
    And I should see "Xanadu Hard Drive CM01"
    And I should see "Hypatia ID"
    And I should see "M1292_CM01"
    And I should see "UUID"
    And I should see "c097de5b-bd21-b95e-944a-769bd46f1928"
    And I should see "druid:ww057vk7675"
    And I should see "Project : Xanadu"

  Scenario: Xanadu item object technical information should include the contentMetadata Object id
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then I should see "Content Object ID"
    And I should see "druid:tk694zs2244"

  Scenario: Xanadu item object  contentMetadata (contained files)
    # file name, downloadable link, file size
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    # Then there should be 3 rows in the table    
    Then I should see "CM01.dd"
    And I should see "CM01.txt"
    And I should see "CM01.csv"
    
  Scenario: images of the media should not be included in downloadable files
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then I should not see "CM01_01.JPG"
    And I should not see "CM01_02.JPG"


  Scenario: Xanadu item object contained files are downloadable
    # the download link works ... probably this should be coded in more generic place
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    # and I follow download link ...
    Then outcome

  Scenario: images of the media should display as thumbnails
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then outcome
    

  Scenario: Nested collections chain at left
    # follow link to immediate parent, and link to root of collection
    #   and possibly any links in between
    #  probably this scenario should be in a more generic place
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then outcome
  
  
  
  
  
  