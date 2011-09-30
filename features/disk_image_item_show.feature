Feature: Disk Image Item Show page
  As a user
  I want to see Disk Image Item object data displaying properly

  Scenario: links to parents (collections or sets) of this object
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "Member of"
    And I should see a link to the show page for "hypatia:fixture_coll2"

  Scenario: links to members (children) of this object
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "In this Collection"
    And I should see a link to the show page for "hypatia:fixture_ftk_file_item"

  Scenario: all desired Description metadata displays
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "CM058"  # title
    Then I should see "CM058 as id"  # local_id
    And I should see "3.5 inch Floppy Disk" # extent
    And I should see "Born Digital" # digital_origin

  Scenario: all desired Repository metadata displays
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "CM058 as id"  # local_id

  Scenario: all desired Technical metadata displays
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "Disk Image File" # title of subsection
    And I should see "CM058.dd" # dd_filename
    And I should see "hypatia:fixture_file_asset_dd_for_media_item" # dd_fedora_pid 
    And I should see "DS1" # dd_ds_id
    And I should see "47570" # dd_size
    And I should see "application/octet-stream" # dd_mimetype
    And I should see "856d7eae922f80e68c954d2e3521f74a" # dd_md5
    And I should see "1a79a23e7827ee62370850def76afdeccf3fbadb" # dd_sha1

    And I should see "Image of Disk - Back" # title of subsection
    And I should see "fixture_media_item_front.jpg" # image_front_filename
    And I should see "hypatia:fixture_file_asset_image1_for_media_item" # image_front_fedora_pid 
    And I should see "DS1" # image_front_ds_id
    And I should see "302081" # image_front_size
    And I should see "image/jpeg" # image_front_mimetype
    And I should see "856d7eae922f80e68c954d2e3521f74ab" # image_front_md5
    And I should see "1a79a23e7827ee62370850def76afdeccf3fbadbc" # image_front_sha1
    
    And I should see "Image of Disk - Back" # title of subsection
    And I should see "fixture_media_item_back.jpg" # image_back_filename
    And I should see "hypatia:fixture_file_asset_image2_for_media_item" # image_back_fedora_pid 
    And I should see "DS1" # image_back_ds_id
    And I should see "302084" # image_back_size
    And I should see "image/jpeg" # image_back_mimetype
    And I should see "856d7eae922f80e68c954d2e3521f74abc" # image_back_md5
    And I should see "1a79a23e7827ee62370850def76afdeccf3fbadbcd" # image_back_sha1

  Scenario: link to download the disk image's DD file
    When I am on the document page for id "hypatia:fixture_media_item"
    Then I should see "CM058.dd" # dd_filename
    And I should see "47570" # dd_size
    And I should see "application/octet-stream" # dd_mimetype
    And I should see a link to datastream "DS1" in FileAsset object "hypatia:fixture_file_asset_dd_for_media_item"
    
# TODO this needs more work
  Scenario: Images of Disk should display
    When I am on the document page for id "hypatia:fixture_media_item" 
    Then I should see "fixture_media_item_front.jpg"  # alt text?
    Then I should see "fixture_media_item_back.jpg"  # alt text?
    Then I should not see a link to datastream "DS1" in FileAsset object "hypatia:fixture_file_asset_image1_for_media_item"
    Then I should not see a link to datastream "DS1" in FileAsset object "hypatia:fixture_file_asset_image2_for_media_item"
    
