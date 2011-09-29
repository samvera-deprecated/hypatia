# defines the OM (Opinionated Metadata) terminology for a Hypatia 
#  DISK IMAGE ITEM object's contentMetadata datastream
class HypatiaDiskImgContentMetadataDS < ActiveFedora::NokogiriDatastream 

# TODO: what should really be searchable, facetable, displayable, sortable?
   
  set_terminology do |t|
    t.root(:path=>"contentMetadata", :xmlns => '', :namespace_prefix => nil) 

    t.my_fedora_id(:path=>"contentMetadata/@objectId", :namespace_prefix => nil)

    t.resource(:namespace_prefix => nil) {
      t.fedora_pid(:path=>{:attribute=>"objectId"}, :namespace_prefix => nil)
      t.file(:ref=>[:file], :namespace_prefix => nil)
    }
    t.file(:namespace_prefix => nil) {
      t.ds_id(:path=>"location", :attributes=>{:type=>"datastreamID"}, :namespace_prefix => nil)
      t.filename(:path=>{:attribute=>"id"}, :namespace_prefix => nil)
      t.size(:path=>{:attribute=>"size"}, :namespace_prefix => nil)
      t.mimetype(:path=>{:attribute=>"mimetype"}, :namespace_prefix => nil)
      t.md5(:path=>"checksum", :attributes=>{:type=>"md5"}, :namespace_prefix => nil)
      t.sha1(:path=>"checksum", :attributes=>{:type=>"sha1"}, :namespace_prefix => nil)
    }
    #  really want ead where the type is ead and the file format is XML and the file mimetype is text/xml (and the file id is (?coll_ead.xml ... can be whatever the label of the DS is in the FileAsset object)) 
    t.dd(:ref=>:resource, :attributes=>{:type=>"media-file"}) 
    t.image_front(:ref=>:resource, :attributes=>{:type=>"image-front"})
    t.image_back(:ref=>:resource, :attributes=>{:type=>"image-back"})

    t.dd_fedora_pid(:proxy=>[:dd, :fedora_pid])
    t.dd_ds_id(:proxy=>[:dd, :file, :ds_id])
    t.dd_filename(:proxy=>[:dd, :file, :filename])
    t.dd_size(:proxy=>[:dd, :file, :size])
    t.dd_mimetype(:proxy=>[:dd, :file, :mimetype])
    t.dd_md5(:proxy=>[:dd, :file, :md5])
    t.dd_sha1(:proxy=>[:dd, :file, :sha1])
    
    t.image_front_fedora_pid(:proxy=>[:image_front, :fedora_pid])
    t.image_front_ds_id(:proxy=>[:image_front, :file, :ds_id])
    t.image_front_filename(:proxy=>[:image_front, :file, :filename])
    t.image_front_size(:proxy=>[:image_front, :file, :size])
    t.image_front_mimetype(:proxy=>[:image_front, :file, :mimetype])
    t.image_front_md5(:proxy=>[:image_front, :file, :md5])
    t.image_front_sha1(:proxy=>[:image_front, :file, :sha1])

    t.image_back_fedora_pid(:proxy=>[:image_back, :fedora_pid])
    t.image_back_ds_id(:proxy=>[:image_back, :file, :ds_id])
    t.image_back_filename(:proxy=>[:image_back, :file, :filename])
    t.image_back_size(:proxy=>[:image_back, :file, :size])
    t.image_back_mimetype(:proxy=>[:image_back, :file, :mimetype])
    t.image_back_md5(:proxy=>[:image_back, :file, :md5])
    t.image_back_sha1(:proxy=>[:image_back, :file, :sha1])

  end # set_terminology

end # class