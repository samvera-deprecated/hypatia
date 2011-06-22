Feature: Xanadu Item Object Show View Fixtures
  I want to ensure Xanadu item objects display correctly in the show view

  Scenario: Xanadu item object  descMetadata
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    And I should see "CM01"
    And I should see "1.0 computer media"
    And I should see "hard drive"
    And I should see "born digital"
    And I should see "Born-Digital Materials - Carton 11 - Computer disks / tapes"
    And I should see "The capacity of CM01 is"

  Scenario: Xanadu item object  technical information (from Fedora, not EAD)
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    # repository object ID
    Then I should see "hypatia:fixture_xanadu_drive1"
  
  
  

  Scenario: Xanadu item object  contentMetadata (contained files)
    # file name, downloadable link, file size
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then outcome

  Scenario: Xanadu item object contained files are downloadable
    # the download link works ... probably this is in more generic place
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then outcome
  
  Scenario: Nested collections chain at left
    # follow link to immediate parent, and link to root of collection
    #   and possibly any links in between
    #  probably this scenario should be in a more generic place
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then outcome
  
  
  
  
  
  