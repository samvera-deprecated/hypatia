# defines the expected OM terminology for a Hypatia collection object's descMetadata 
#  datastream, which will have Mods XML.
class HypatiaCollDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd", :namespace_prefix => "mods")

    t.title_info(:path=>"titleInfo") {
      t.title(:path=>"title", :index_as=>[:searchable, :displayable, :sortable], :label=>"title")
    }
    t.title(:proxy=>[:title_info, :title])
    
    t.name_ {
      t.name_part
      t.role(:ref=>[:role])
      t.family_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.given_name(:path=>"namePart", :attributes=>{:type=>"given"}, :label=>"first name")
      t.terms_of_address(:path=>"namePart", :attributes=>{:type=>"termsOfAddress"})
    }
    t.role {
      t.text(:path=>"roleTerm", :attributes=>{:type=>"text"})
    }
# FIXME:  would like a way to split out "creator" name and other role names specifically
    t.person(:ref=>:name, :attributes=>{:type=>"personal"}) 
    t.institution(:ref=>:name, :attributes=>{:type=>"corporate"})

    t.local_id(:path=>"identifier", :attributes=>{:type=>"local"}, :index_as=>[:searchable, :displayable, :sortable])

    t.origin_info(:path=>"originInfo") {
      t.date_created(:path=>"dateCreated", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    }
    t.create_date(:proxy=>[:origin_info, :date_created])

    t.location(:path=>"location") {
      t.located_in(:path=>"physicalLocation", :attributes=>{:displayLabel=>"Located in"})
    }
    t.located_in(:proxy=>[:location, :located_in])

    t.language_info(:path=>"language") {
      t.language_code(:path=>"languageTerm", :index_as=>[:searchable, :displayable, :facetable, :sortable])
    }
    t.lang_code(:proxy=>[:language_info, :language_code])



    t.genre(:path=>"genre", :index_as=>[:searchable, :displayable, :facetable, :sortable])
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
    

    # proxy declarations
    
    t.extent(:proxy=>[:physical_desc, :extent])
    t.language(:proxy=>[:language_info, :language_code])
    t.local_role(:proxy=>[:role, :text])
    t.topic(:proxy=>[:subject, :topic])
    

  end # set_terminology

end # class