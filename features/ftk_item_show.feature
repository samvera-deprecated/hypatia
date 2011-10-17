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
    And I should see "CM006.001/NONAME [FAT12]/[root]/BU3A5"  # filepath
    And I should see "35654" # extent
    And I should see "Punch Cards" # extent
    And I should see "WordPerfect 4.2" # filetype
    And I should see "born digital" # <digitalOrigin> (constant)
    And I should see "12/6/1988" # date_created
    And I should see "12/10/1988" # date_last_accessed
    And I should see "12/8/1988 6:48:48 AM (1988-12-08 14:48:48 UTC)" # date_last_modified
    And I should see "Journal Article" # note_plain
    And I should see "The Burgess Shale and the Nature of History" # addl_title

  Scenario: all desired Repository metadata displays
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
    Then I should see "1004"  # ftk_id

  Scenario: all desired Technical metadata displays
    When I am on the document page for id "hypatia:fixture_ftk_file_item" 
    Then I should see "hypatia:fixture_ftk_file_item" # my_fedora_id
    And I should see "hypatia:fixture_file_asset_for_ftk_file_item" # pid of FileAsset object

    And I should see "Content File" # title of subsection
    And I should see "BURCH1" # content_filename
    And I should see "35654" # content_size
    And I should see "BINARY" # content_format
    And I should see "application/octet-stream" # content_mimetype
    And I should see "5E3A2508EA8A8D7E62657D99DAE503ED" # content_md5
    And I should see "E876FA363FAFDC6784C5EE75E8F9EA9FF11EC9FF" # content_sha1
    And I should see "content" # content_ds_id

    And I should see "Derivative Display File" # title of subsection
    And I should see "BURCH1.html" # html_filename
    And I should see "12346" # html_size
    And I should see "HTML" # html_format
    And I should see "text/html" # html_mimetype
    And I should see "5E3A2508EA8A8D7E62657D99DAE503EDMORE" # html_md5
    And I should see "E876FA363FAFDC6784C5EE75E8F9EA9FF11EC9FFDIFF" # html_sha1
    And I should see "derivative_html" # html_ds_id

  Scenario: links to download files
    When I am on the document page for id "hypatia:fixture_ftk_file_item"
    Then I should see "BURCH1" # content_filename
    And I should see "35654" # content_size
    And I should see "application/octet-stream" # content_mimetype
    And I should see a link to datastream "content" in FileAsset object "hypatia:fixture_file_asset_for_ftk_file_item"
    And I should see "BURCH1.html" # html_filename
    And I should see "12346" # html_size
    And I should see "text/html" # html_mimetype
    And I should see a link to datastream "derivative_html" in FileAsset object "hypatia:fixture_file_asset_for_ftk_file_item"
  