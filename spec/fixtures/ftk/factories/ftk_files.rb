require 'factory_girl'
# This will guess the FtkFile class
FactoryGirl.define do
  factory :ftk_file do
    filename 'BURCH1'
    id '9999'
    filesize '504 B'
    filetype "WordPerfect 5.1"
    filepath "CM5551212.001/NONAME [FAT12]/[root]/NATHIN32"
    disk_image_name "CM5551212"
    file_creation_date "6/14/1996 4:46:26 AM (1996-06-14 11:46:26 UTC)"
    file_accessed_date "12/8/1998 6:48:48 AM (1998-12-08 14:48:48 UTC)"
    file_modified_date "10/20/1998 10:44:46 AM (1998-10-20 17:44:46 UTC)"
    medium "Punch Cards"
    title 'A Heartbreaking Work of Staggering Genius'
    access_rights "Public"
    duplicate "M"
    restricted "False"
    md5 "4E1AA0E78D99191F4698EEC437569D23"
    sha1 "B6373D02F3FD10E7E1AA0E3B3AE3205D6FB2541C"
    export_path "files/BURCH1"
    type "Journal Article"
  end
end