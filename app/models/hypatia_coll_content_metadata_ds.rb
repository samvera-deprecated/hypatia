# defines the OM (Opinionated Metadata) terminology for a Hypatia COLLECTION 
#  object's contentMetadata datastream
class HypatiaCollContentMetadataDS < ActiveFedora::NokogiriDatastream 

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
    t.ead(:ref=>:resource, :attributes=>{:type=>"ead"}) 
    t.image(:ref=>:resource, :attributes=>{:type=>"image"})

    t.ead_fedora_pid(:proxy=>[:ead, :fedora_pid])
    t.ead_ds_id(:proxy=>[:ead, :file, :ds_id])
    t.ead_filename(:proxy=>[:ead, :file, :filename])
    t.ead_size(:proxy=>[:ead, :file, :size])
    t.ead_mimetype(:proxy=>[:ead, :file, :mimetype])
    t.ead_md5(:proxy=>[:ead, :file, :md5])
    t.ead_sha1(:proxy=>[:ead, :file, :sha1])
    
    t.image_fedora_pid(:proxy=>[:image, :fedora_pid])
    t.image_ds_id(:proxy=>[:image, :file, :ds_id])
    t.image_filename(:proxy=>[:image, :file, :filename])
    t.image_size(:proxy=>[:image, :file, :size])
    t.image_mimetype(:proxy=>[:image, :file, :mimetype])
    t.image_md5(:proxy=>[:image, :file, :md5])
    t.image_sha1(:proxy=>[:image, :file, :sha1])

  end # set_terminology

end # class