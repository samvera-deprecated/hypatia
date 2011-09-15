Feature: Xanadu Item Object Show View 
  I want to ensure Xanadu item objects display correctly in the show view

  Scenario: Xanadu item object descMetadata
    When I am on the document page for id "hypatia:fixture_xanadu_drive1"
    Then I should see "CM01"
    And I should see "1.0 computer media"
    And I should see "hard drive"
    And I should see "born digital"
    And I should see "Born-Digital Materials - Carton 11 - Computer disks / tapes"
    And I should see "The capacity of CM01 is"

  Scenario: Xanadu item object technical information should include the contentMetadata Object id
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then I should see "Content Object ID"
    And I should see "druid:tk694zs2244"

  Scenario: Xanadu item object  contentMetadata (contained files)
    # file name, downloadable link, file size
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    # Then there should be 3 rows in the table    
    Then I should see "CM01.dd"
# FIXME:  the fixture data for disk image items needs to be redone - this is non-functional    
#    And I should see "CM01.txt"
#    And I should see "CM01.csv"
    
  # Scenario: Xanadu item object contained files are downloadable
  #   # the download link works ... probably this should be coded in more generic place
  #   When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
  #   # and I follow download link ...
  #   Then outcome

  Scenario: images of the media should not be included in downloadable files
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
    Then I should not see "CM01_01.JPG"
    And I should not see "CM01_02.JPG"
  
  # Scenario: images of the media should display as thumbnails
  #   When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
  #   Then outcome
    
  Scenario: Sets this item belongs to should display as links
    When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
#    Then I should see a "div" element with a "class" attribute of "sets"
    Then I should see a link to "the show page for hypatia:fixture_xanadu_collection" with label "Keith Henson. Papers relating to Project Xanadu, XOC and Eric Drexler"

  # Scenario: Nested collections chain at left
  #   # follow link to immediate parent, and link to root of collection
  #   #   and possibly any links in between
  #   #  probably this scenario should be in a more generic place
  #   When I am on the document page for id "hypatia:fixture_xanadu_drive1" 
  #   Then outcome
  