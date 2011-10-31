# defines the OM terminology for a Hypatia FTK ITEM object's 
#  descMetadata datastream, which will have Mods XML.
class HypatiaFTKItemDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
# TODO: what should really be searchable, facetable, displayable, sortable?

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

    t.filename(:path=>"identifier", :attributes=>{:type=>"filename"}, :index_as=>[:searchable, :displayable, :sortable])
    t.display_name(:proxy=>[:filename], :index_as=>[:searchable, :displayable, :sortable, :facetable])
    
    t.ftk_id(:path=>"identifier", :attributes=>{:type=>"ftk_id"}, :index_as=>[:searchable, :displayable, :sortable])

    t.location(:path=>"location") {
      t.filepath(:path=>"physicalLocation", :attributes=>{:type=>"filepath"}, :index_as=>[:displayable])
    }
    t.filepath(:proxy=>[:location, :filepath], :index_as=>[:displayable])
    
    t.filetype(:path=>"note", :attributes=>{:displayLabel=>"filetype"}, :index_as=>[:searchable, :displayable, :facetable])
    t.note_plain(:path=>"note", :attributes=>{:displayLabel=>:none}, :index_as=>[:searchable, :displayable, :facetable])

    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:path=>"extent", :index_as=>[:searchable, :displayable, :facetable])
      t.digital_origin(:path=>"digitalOrigin", :index_as=>[:displayable])
    }
    t.extent(:proxy=>[:physical_desc, :extent])
    t.digital_origin(:proxy=>[:physical_desc, :digital_origin])

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
  
  # Generates an empty Mods record (used when you call HypatiaFtkItem.new without passing in existing xml)
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
         "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
         "xmlns"=>"http://www.loc.gov/mods/v3",
         "xsi:schemaLocation"=>"http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd",
         :namespace_prefix => "mods", "xmlns:mods" => "http://www.loc.gov/mods/v3") {
      }
    end
    return builder.doc
  end
  

end