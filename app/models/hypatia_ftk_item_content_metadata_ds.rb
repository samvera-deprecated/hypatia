# defines the OM (Opinionated Metadata) terminology for a Hypatia FTK ITEM 
#  object's contentMetadata datastream
class HypatiaFTKItemContentMetadataDS < ActiveFedora::NokogiriDatastream 

# TODO: what should really be searchable, facetable, displayable, sortable?
   
  set_terminology do |t|
    t.root(:path=>"contentMetadata", :xmlns => '', :namespace_prefix => nil) 

    t.my_fedora_id(:path=>"contentMetadata/@objectId", :namespace_prefix => nil)

    t.resource(:namespace_prefix => nil) {
      t.fedora_pid(:path=>{:attribute=>"objectId"}, :namespace_prefix => nil)
      t.file(:ref=>[:file], :namespace_prefix => nil)
    }
    t.file_asset_fedora_id(:proxy=>[:resource, :fedora_pid])

    t.file(:namespace_prefix => nil) {
      t.ds_id(:path=>"location", :attributes=>{:type=>"datastreamID"}, :namespace_prefix => nil)
      t.filename(:path=>{:attribute=>"id"}, :namespace_prefix => nil)
      t.size(:path=>{:attribute=>"size"}, :namespace_prefix => nil)
      t.format(:path=>{:attribute=>"format"}, :namespace_prefix => nil)
      t.mimetype(:path=>{:attribute=>"mimetype"}, :namespace_prefix => nil)
      t.md5(:path=>"checksum", :attributes=>{:type=>"md5"}, :namespace_prefix => nil)
      t.sha1(:path=>"checksum", :attributes=>{:type=>"sha1"}, :namespace_prefix => nil)
    }
    t.content(:ref=>:file, :path=>'resource/file[location="content"]', :namespace_prefix => nil)
    t.html(:ref=>:file, :path=>'resource/file[location="derivative_html"]', :namespace_prefix => nil)

    t.content_ds_id(:proxy=>[:content, :ds_id])
    t.content_filename(:proxy=>[:content, :filename])
    t.content_size(:proxy=>[:content, :size])
    t.content_format(:proxy=>[:content, :format])
    t.content_mimetype(:proxy=>[:content, :mimetype])
    t.content_md5(:proxy=>[:content, :md5])
    t.content_sha1(:proxy=>[:content, :sha1])

    t.html_ds_id(:proxy=>[:html, :ds_id])
    t.html_filename(:proxy=>[:html, :filename])
    t.html_size(:proxy=>[:html, :size])
    t.html_format(:proxy=>[:html, :format])
    t.html_mimetype(:proxy=>[:html, :mimetype])
    t.html_md5(:proxy=>[:html, :md5])
    t.html_sha1(:proxy=>[:html, :sha1])

  end # set_terminology

end # class