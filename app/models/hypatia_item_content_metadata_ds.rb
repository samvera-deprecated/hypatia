# defines the expected OM terminology for a Hypatia item object's contentMetadata 
#  datastream, which will have Mods XML.
class HypatiaItemContentMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"contentMetadata", :xmlns => '', :namespace_prefix => nil)

    t.content_oid(:path=>{:attribute=>"objectId"}, :index_as=>[:searchable, :displayable], :namespace_prefix => nil)

# associating a sub-sub element or attribute with contentMetadata top element ... maybe should just do inline with unique term
#    t.photo_resource(:path=>"resource", :attributes=>{:type=>"photo"}, :index_as=>[:searchable,  :displayable])

    t.resource (:namespace_prefix => nil){
# these are attributes on resource element      
#      t.id
#      t.data
#      t.object_id(:path=>{:attribute=>"objectId"}, :index_as=>[:displayable])
      t.resource_oid(:path=>{:attribute=>"objectId"}, :index_as=>[:searchable, :displayable], :namespace_prefix => nil)
      t.resource_type(:path=>{:attribute=>"type"}, :index_as=>[:searchable, :displayable], :namespace_prefix => nil)
      t.file(:path=>"file", :namespace_prefix => nil) {
# these are attributes on file elements
#        t.file_id(:path=>{:attribute=>"id"}, :index_as=>[:searchable, :displayable])
#        t.format(:path=>{:attribute=>"format"}, :index_as=>[:searchable, :facetable, :displayable])
        t.mime(:path=>{:attribute=>"mimeytpe"}, :index_as=>[:searchable, :facetable, :displayable], :namespace_prefix => nil)
#        t.size(:path=>{:attribute=>"size"}, :index_as=>[:searchable, :facetable, :displayable])
#        t.preserve(:xpath=>"//file@preserve", :index_as=>[:displayable, :facetable])
#        t.shelve(:xpath=>"//file@shelve", :index_as=>[:displayable, :facetable])
#        t.deliver(:xpath=>"//file@display", :index_as=>[:displayable, :facetable])
        
        t.urla(:path=>"location", :attributes=>{:type=>"url"}, :index_as=>[:displayable, :searchable], :namespace_prefix => nil)
        t.location(:path=>"location", :attributes=>{:type=>"url"}, :index_as=>[:displayable], :namespace_prefix => nil)
        t.checksum_md5(:path=>"checksum", :attributes=>{:type=>"md5"}, :index_as=>[:displayable], :namespace_prefix => nil)
        t.checksum_sha1(:path=>"checksum", :attributes=>{:type=>"sha1"}, :index_as=>[:displayable], :namespace_prefix => nil)
      }
    }
    
    # proxy declarations
    t.cont_oid(:proxy => [:contentMetadata, :content_oid])

 #    t.file_id(:proxy=>[:resource, :file, :id])
#    t.file_mime(:proxy=>[:resource, :file, :mime])
    t.file_location(:proxy=>[:resource, :file, :location])
    t.url(:proxy=>[:resource, :file, :urla])


  end # set_terminology

end # class