# defines the OM terminology for a Hypatia SET object's descMetadata 
#  datastream, which will have Mods XML.
class HypatiaSetDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd", :namespace_prefix => "mods", "xmlns:mods" => "http://www.loc.gov/mods/v3")

    t.title_info(:path=>"titleInfo") {
      t.title(:index_as=>[:searchable, :displayable, :sortable, :facetable])
    }
    t.title(:proxy=>[:title_info, :title])
    t.display_name(:proxy=>[:title_info, :title], :index_as=>[:searchable, :displayable, :sortable, :facetable])
    
    t.origin_info(:path=>"originInfo") {
      t.date_created(:path=>"dateCreated", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    }
    t.create_date(:proxy=>[:origin_info, :date_created])

    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:index_as=>[:searchable])
    }
    t.extent(:proxy=>[:physical_desc, :extent])

    t.scope_and_content(:path=>"abstract", :attributes=>{:displayLabel=>"Scope and Contents"}, :index_as=>[:searchable, :displayable])

    t.local_id(:path=>"identifier", :attributes=>{:type=>"local"}, :index_as=>[:searchable, :displayable, :sortable, :facetable])

    t.note(:index_as=>[:searchable, :displayable])

  end # set_terminology

  # Generates an empty Mods record (used when you call HypatiaSet.new without passing in existing xml)
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

end # class