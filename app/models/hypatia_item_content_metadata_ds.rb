# defines the expected OM terminology for a Hypatia item object's contentMetadata 
#  datastream, which will have Mods XML.
class HypatiaItemContentMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"contentMetadata", :xmlns => '', :namespace_prefix => nil)

    t.resource(:namespace_prefix => nil) {

      t.resource_id(:path=>{:attribute=>"id"}, :index_as=>[:searchable, :displayable, :facetable], :namespace_prefix => nil)
      t.resource_type(:path=>{:attribute=>"type"}, :index_as=>[:searchable, :displayable], :namespace_prefix => nil)
# FIXME: want this sortable, but sort field can't be multi-valued ... but at resource element level, it really isn't multi-valued
      t.resource_object_id(:path=>{:attribute=>"objectId"}, :index_as=>[:searchable, :displayable], :namespace_prefix => nil)

      t.file(:path=>"file", :namespace_prefix => nil) {

        t.file_id(:path=>{:attribute=>"id"}, :index_as=>[:displayable], :namespace_prefix => nil)
        t.file_format(:path=>{:attribute=>"format"}, :index_as=>[:searchable, :displayable, :facetable], :namespace_prefix => nil)
        t.file_mimetype(:path=>{:attribute=>"mimetype"}, :index_as=>[:searchable, :displayable, :facetable], :namespace_prefix => nil)
# FIXME: want this sortable, but sort field can't be multi-valued ... but at file element level, it really isn't multi-valued
        t.file_size(:path=>{:attribute=>"size"}, :index_as=>[:searchable, :displayable], :namespace_prefix => nil)
#        t.preserve(:path=>{:attribute=>"preserve"}, :index_as=>[:displayable, :facetable])
#        t.shelve(:path=>{:attribute=>"shelve"}, :index_as=>[:displayable, :facetable])
#        t.deliver(:path=>{:attribute=>"deliver"}, :index_as=>[:displayable, :facetable])
        
        t.file_url(:path=>"location", :attributes=>{:type=>"url"}, :index_as=>[:displayable], :namespace_prefix => nil)
#        t.checksum_md5(:path=>"checksum", :attributes=>{:type=>"md5"}, :index_as=>[:displayable], :namespace_prefix => nil)
#        t.checksum_sha1(:path=>"checksum", :attributes=>{:type=>"sha1"}, :index_as=>[:displayable], :namespace_prefix => nil)
      }
    }
    
    # proxy declarations
    t.resource_id(:proxy => [:resource, :resource_id])
    t.resource_type(:proxy => [:resource, :resource_type])
    t.resource_object_id(:proxy => [:resource, :resource_object_id])

    t.file_id(:proxy=>[:resource, :file, :file_id])
    t.file_format(:proxy=>[:resource, :file, :file_format])
    t.format(:proxy=>[:resource, :file, :file_format])
    t.file_mimetype(:proxy=>[:resource, :file, :file_mimetype])
    t.mimetype(:proxy=>[:resource, :file, :file_mimetype])
    t.file_size(:proxy=>[:resource, :file, :file_size])
    t.size(:proxy=>[:resource, :file, :file_size])
    t.file_url(:proxy=>[:resource, :file, :file_url])
    t.url(:proxy=>[:resource, :file, :file_url])

  end # set_terminology

end # class