# defines the expected OM terminology for a Hypatia set object's descMetadata 
#  datastream, which will have Mods XML.
class HypatiaSetDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd", :namespace_prefix => "mods")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:path=>"title", :index_as=>[:searchable, :displayable, :sortable], :label=>"title")
    }
# trying it  - didn't work  
    t.creator(:xpath=>"//name/namePart[../role/roleTerm.text()='creator']", :namespace_prefix => "mods", :index_as=>[:searchable, :displayable, :facetable, :sortable])
# trying it - didn't work
    t.repository(:xpath=>"//name[@type=corporate]/namePart[../role/roleTerm.text()='repository']", :namespace_prefix => "mods", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    t.genre(:path=>"genre", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    t.origin_info(:path=>"originInfo") {
      t.date_created(:path=>"dateCreated", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    }
    t.language_info(:path=>"language") {
      t.language_code(:path=>"languageTerm", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    }
# trying it - didn't work
    t.lang_code(:xpath=>"//language/languageTerm", :namespace_prefix => "mods", :index_as=>[:searchable, :displayable, :facetable, :sortable])
# FIXME:  want "extent" more than "physical_desc" ... yes?
    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:path=>"extent", :index_as=>[:searchable])
    }

# tried displaylabel = nil ... didn't work    
    t.abstract(:path=>"abstract",  :attributes=>{:displayLabel=>nil}, :index_as=>[:searchable, :displayable])
    t.scope_and_summary(:path=>"abstract", :attributes=>{:displayLabel=>"Collection Scope and Content Summary"}, :index_as=>[:searchable, :displayable])
    t.biography(:path=>"abstract", :attributes=>{:displayLabel=>"Biography"}, :index_as=>[:searchable, :displayable])
    t.acquisition_info(:path=>"abstract", :attributes=>{:displayLabel=>"Acquisition Information"}, :index_as=>[:searchable, :displayable])
    t.citation(:path=>"abstract", :attributes=>{:displayLabel=>"Preferred Citation"}, :index_as=>[:searchable, :displayable])
    
    t.subject(:path=>"subject") {
      t.topic(:path=>"topic", :index_as=>[:searchable, :displayable, :facetable])
    }

    t.use_and_repro_rights(:path=>"accessCondition", :attributes=>{:displayLabel=>"Publication Rights", :type=>"useAndReproduction"}, :index_as=>[:displayable])
    t.access(:path=>"accessCondition", :attributes=>{:displayLabel=>"Access", :type=>"restrictionOnAccess"}, :index_as=>[:displayable])
    
    t.identifier(:path=>"identifier", :index_as=>[:searchable, :displayable, :sortable])


    # This is a mods:name.  The underscore is purely to avoid namespace conflicts.
    t.name_ {
      t.name_part
#      t.role(:ref=>[:role])
      t.family_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.given_name(:path=>"namePart", :attributes=>{:type=>"given"}, :label=>"first name")
      t.terms_of_address(:path=>"namePart", :attributes=>{:type=>"termsOfAddress"})
    }

=begin not useful?
    # mods:role, which is used within mods:namePart elements
    t.role {
      t.text(:path=>"roleTerm", :attributes=>{:type=>"text"})
      t.authority(:path=>"roleTerm", :attributes=>{:type=>"marcrelator"})
    }
=end
    
    # Re-use the structure of a :name Term with a different @type attribute
    t.person(:ref=>:name, :attributes=>{:type=>"personal"})
    t.organization(:ref=>:name, :attributes=>{:type=>"corporate"})


    # proxy declarations
    t.title(:proxy=>[:title_info, :main_title])
    t.create_date(:proxy=>[:origin_info, :date_created])
    t.language(:proxy=>[:language_info, :language_code])

  end # set_terminology

end # class