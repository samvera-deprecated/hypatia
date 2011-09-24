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

    t.physical_desc(:path=>"physicalDescription") {
      t.extent(:path=>"extent", :index_as=>[:searchable])
    }
    t.extent(:proxy=>[:physical_desc, :extent])

    t.genre(:path=>"genre", :index_as=>[:searchable, :displayable, :facetable, :sortable])

    t.abstract(:path=>"abstract", :attributes=>{:displayLabel=>:none}, :index_as=>[:searchable, :displayable])
    t.biography(:path=>"abstract", :attributes=>{:displayLabel=>"Biography"}, :index_as=>[:searchable, :displayable])
    t.acquisition_info(:path=>"abstract", :attributes=>{:displayLabel=>"Acquisition Information"}, :index_as=>[:searchable, :displayable])
    t.provenance(:path=>"abstract", :attributes=>{:displayLabel=>"Provenance"}, :index_as=>[:searchable, :displayable])
# FIXME:  would like to be able to match a regular expression to allow for some variation in the displayLabel attribute value /.*Cit.+/
#  OR  would like to match multiple terms here to a single term
    t.citation(:path=>"abstract", :attributes=>{:displayLabel=>"Preferred Citation"}, :index_as=>[:searchable, :displayable])
    t.description(:path=>"abstract", :attributes=>{:displayLabel=>"Description of the Papers"}, :index_as=>[:searchable, :displayable])
    t.scope_and_content(:path=>"abstract", :attributes=>{:displayLabel=>"Scope and Contents"}, :index_as=>[:searchable, :displayable])
    
    t.subject_all(:path=>"subject") {
      t.topic(:path=>"topic", :index_as=>[:searchable, :displayable, :facetable])
    }
    t.subject_plain(:path=>"subject", :attributes=>{:authority=>:none}) {
      t.topic(:path=>"topic", :index_as=>[:searchable, :displayable, :facetable])
    }
    t.subject_lcsh(:path=>"subject", :attributes=>{:authority=>"lcsh"}) {
      t.topic(:path=>"topic", :index_as=>[:searchable, :displayable, :facetable])
    }
    t.subject_ingest(:path=>"subject", :attributes=>{:authority=>"ingest"}) {
      t.topic(:path=>"topic", :index_as=>[:searchable, :displayable, :facetable])
    }
    t.topic(:proxy=>[:subject_all, :topic])
    t.topic_plain(:proxy=>[:subject_plain, :topic])
    t.topic_lcsh(:proxy=>[:subject_lcsh, :topic])
    t.topic_ingest(:proxy=>[:subject_ingest, :topic])

    t.use_and_repro_rights(:path=>"accessCondition", :attributes=>{:displayLabel=>"Publication Rights", :type=>"useAndReproduction"}, :index_as=>[:displayable])
    t.access(:path=>"accessCondition", :attributes=>{:displayLabel=>"Access", :type=>"restrictionOnAccess"}, :index_as=>[:displayable])
    

  end # set_terminology

end # class