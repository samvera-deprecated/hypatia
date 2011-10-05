# defines the OM terminology for a Hypatia COLLECTION object's descMetadata 
#  datastream, which will have Mods XML.
class HypatiaCollDescMetadataDS < ActiveFedora::NokogiriDatastream 
   
# TODO: what should really be searchable, facetable, displayable, sortable?

  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-3.xsd", :namespace_prefix => "mods")

    t.title_info(:path=>"titleInfo") {
      t.title(:path=>"title", :index_as=>[:searchable, :displayable, :sortable], :label=>"title")
    }
    t.title(:proxy=>[:title_info, :title])
    t.display_name(:proxy=>[:title_info, :title], :index_as=>[:searchable, :displayable, :sortable])
    
    t.name_ {
      t.name_part(:path=>"namePart")
      t.family_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.given_name(:path=>"namePart", :attributes=>{:type=>"given"}, :label=>"first name")
      t.terms_of_address(:path=>"namePart", :attributes=>{:type=>"termsOfAddress"})
      t.role(:ref=>[:role])
    }
    t.role {
      t.role_term_text(:path=>"roleTerm", :attributes=>{:type=>"text"})
    }

    t.person_full(:ref=>:name, :attributes=>{:type=>"personal"}) 
    t.person(:proxy=>[:person_full, :name_part])
    t.creator(:ref=>:person, :path=>'name[mods:role/mods:roleTerm="creator"]', :xmlns=>"http://www.loc.gov/mods/v3", :namespace_prefix => "mods")

    t.corporate_full(:ref=>:name, :attributes=>{:type=>"corporate"})
    t.corporate(:proxy=>[:corporate_full, :name_part])
    t.repository(:ref=>:corporate, :path=>'name[mods:role/mods:roleTerm="repository"]', :xmlns=>"http://www.loc.gov/mods/v3", :namespace_prefix => "mods")

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
    t.citation(:path=>"abstract", :attributes=>{:displayLabel=>"Preferred Citation"}, :index_as=>[:searchable, :displayable])
    t.description(:path=>"abstract", :attributes=>{:displayLabel=>"Description of the Papers"}, :index_as=>[:searchable, :displayable])
    t.scope_and_content(:path=>"abstract", :attributes=>{:displayLabel=>"Collection Scope and Content Summary"}, :index_as=>[:searchable, :displayable])
    
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

    t.pub_rights(:path=>"accessCondition", :attributes=>{:displayLabel=>"Publication Rights"}, :index_as=>[:displayable])
    t.access(:path=>"accessCondition", :attributes=>{:displayLabel=>"Access"}, :index_as=>[:displayable])

  end # set_terminology

end # class