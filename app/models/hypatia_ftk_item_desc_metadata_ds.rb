# defines the OM terminology for a Hypatia FTK ITEM object's 
#  descMetadata datastream, which will have Mods XML.
class HypatiaFTKItemDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
# TODO: what should really be searchable, facetable, displayable, sortable?

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

    t.filename(:path=>"identifier", :attributes=>{:type=>"filename"}, :index_as=>[:searchable, :displayable, :sortable])
    t.display_name(:proxy=>[:filename], :index_as=>[:searchable, :displayable, :sortable])
    
    t.ftk_id(:path=>"identifier", :attributes=>{:type=>"ftk_id"}, :index_as=>[:searchable, :displayable, :sortable])

    t.location(:path=>"location") {
      t.filepath(:path=>"physicalLocation", :attributes=>{:type=>"filepath"}, :index_as=>[:displayable])
    }
    t.filepath(:proxy=>[:location, :filepath], :index_as=>[:displayable])
    
    t.filetype(:path=>"note", :attributes=>{:displayLabel=>"filetype"}, :index_as=>[:searchable, :displayable, :facetable])

    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:path=>"extent", :index_as=>[:displayable])
    }
    t.extent(:proxy=>[:physical_desc, :extent])

    t.origin_info(:path=>"originInfo") {
      t.date_created(:path=>"dateCreated", :index_as=>[:displayable, :sortable])
      t.date_last_accessed(:path=>"dateOther", :attributes=>{:type=>"last_accessed"}, :index_as=>[:displayable, :sortable])
      t.date_last_modified(:path=>"dateOther", :attributes=>{:type=>"last_modified"}, :index_as=>[:displayable, :sortable])
    }
    t.date_created(:proxy=>[:origin_info, :date_created])
    t.date_last_accessed(:proxy=>[:origin_info, :date_last_accessed])
    t.date_last_modified(:proxy=>[:origin_info, :date_last_modified])

    t.related_item(:path=>"relatedItem", :attributes=>{:displayLabel=>"Appears in"}) {
      t.title_info(:path=>"titleInfo") {
        t.title(:path=>"title", :index_as=>[:searchable, :displayable, :sortable], :label=>"title")
      }
    }
    t.addl_title(:proxy=>[:related_item, :title_info, :title], :index_as=>[:searchable, :displayable])
  end 

end