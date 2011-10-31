# defines the OM terminology for a Hypatia DISK-IMAGE ITEM object's 
#  descMetadata datastream, which will have Mods XML.
class HypatiaDiskImgDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
# TODO: what should really be searchable, facetable, displayable, sortable?

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd")

    t.title_info(:path=>"titleInfo") {
      # ftk item loader looks for matching disk image on this field; it needs a string so it uses title_sort
      t.title(:path=>"title", :index_as=>[:searchable, :displayable, :sortable], :label=>"title")
    }
    t.title(:proxy=>[:title_info, :title])
    t.display_name(:proxy=>[:title_info, :title], :index_as=>[:searchable, :displayable, :sortable, :facetable])
    
    t.local_id(:path=>"identifier", :attributes=>{:type=>"local"}, :index_as=>[:searchable, :displayable, :sortable, :facetable])

    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:path=>"extent", :index_as=>[:displayable])
      t.digital_origin(:path=>"digitalOrigin", :index_as=>[:displayable])
    }
    t.extent(:proxy=>[:physical_desc, :extent])
    t.digital_origin(:proxy=>[:physical_desc, :digital_origin])
  end 

  # Generates an empty Mods record (used when you call HypatiaDiskImage.new without passing in existing xml)
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