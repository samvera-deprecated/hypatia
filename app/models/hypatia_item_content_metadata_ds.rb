# defines the expected OM terminology for a Hypatia item object's contentMetadata 
#  datastream, which will have Mods XML.
class HypatiaItemContentMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"contentMetadata", :xmlns => '')

# these are attributes on contentMetadata element ...    
#    t.type
#    t.object_id(:xpath=>"@objectId", :index_as=>[:searchable, :displayable])
#    t.object_id(:attributes=>{:type=>"objectId"}, :index_as=>[:searchable, :displayable])
    t.resource (:path=>"resource") {
# these are attributes on resource element      
#      t.id
#      t.type
#      t.data
#      t.object_id(:path=>{:attribute=>"objectId"}, :index_as=>[:displayable])
      t.file (:path=>"file") {
# these are attributes on file elements
#        t.id(:path=>"@id", :index_as=>[:searchable, :displayable])
#        t.format
#        t.mime(:xpath=>"@mimetype", :index_as=>[:displayable, :facetable])
#        t.size
#        t.preserve(:xpath=>"//file@preserve", :index_as=>[:displayable, :facetable])
#        t.shelve(:xpath=>"//file@shelve", :index_as=>[:displayable, :facetable])
#        t.deliver(:xpath=>"//file@display", :index_as=>[:displayable, :facetable])
        
        t.urla(:path=>"location", :attributes=>{:type=>"url"}, :index_as=>[:displayable, :searchable])
        t.location(:path=>"location", :attributes=>{:type=>"url"}, :index_as=>[:displayable])
        t.checksum_md5(:path=>"checksum", :attributes=>{:type=>"md5"}, :index_as=>[:displayable])
        t.checksum_sha1(:path=>"checksum", :attributes=>{:type=>"sha1"}, :index_as=>[:displayable])
      }
    }
    
    # proxy declarations
#    t.file_id(:proxy=>[:resource, :file, :id])
#    t.file_mime(:proxy=>[:resource, :file, :mime])
    t.file_location(:proxy=>[:resource, :file, :location])
    t.url(:proxy=>[:resource, :file, :urla])

  end # set_terminology

end # class