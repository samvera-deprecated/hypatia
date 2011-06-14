# defines the expected OM terminology for a Hypatia item object's descMetadata 
#  datastream, which will have Mods XML.
class HypatiaItemDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :index_as=>[:searchable, :displayable, :sortable], :label=>"title")
    }

    t.extent(:path=>"extent", :index_as=>[:searchable])
    t.digital_origin(:path=>"digitalOrigin", :index_as=>[:searchable])
    
    t.located_in(:path=>"note", :attributes=>{:displayLabel=>"Located in"}, :index_as=>[:displayable])

    t.processing_info(:path=>"abstract", :attributes=>{:displayLabel=>"Processing Information note"}, :index_as=>[:searchable, :displayable])
    
    t.identifier(:path=>"identifier", :index_as=>[:searchable, :displayable, :sortable])

    # proxy declarations
    t.title(:proxy=>[:title_info, :main_title])

  end # set_terminology

end # class