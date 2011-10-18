# defines the OM terminology for a Hypatia SET object's descMetadata 
#  datastream, which will have Mods XML.
class HypatiaSetDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd", :namespace_prefix => "mods")

    t.title_info(:path=>"titleInfo") {
      t.title(:index_as=>[:searchable, :displayable, :sortable])
    }
    t.title(:proxy=>[:title_info, :title])
    t.display_name(:proxy=>[:title_info, :title], :index_as=>[:searchable, :displayable, :sortable])
    
    t.origin_info(:path=>"originInfo") {
      t.date_created(:path=>"dateCreated", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    }
    t.create_date(:proxy=>[:origin_info, :date_created])

    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:index_as=>[:searchable])
    }
    t.extent(:proxy=>[:physical_desc, :extent])

    t.scope_and_content(:path=>"abstract", :attributes=>{:displayLabel=>"Scope and Contents"}, :index_as=>[:searchable, :displayable])

    t.local_id(:path=>"identifier", :attributes=>{:type=>"local"}, :index_as=>[:searchable, :displayable, :sortable])

    t.note(:index_as=>[:searchable, :displayable])

  end # set_terminology

end # class