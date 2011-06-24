# defines the expected OM terminology for a DOR identityMetadata datastream
class DorIdentityMetadataDS < ActiveFedora::NokogiriDatastream 
  
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"identityMetadata", :xmlns => '')

    # in alphabetical order
    t.admin_policy(:path=>"adminPolicy", :index_as=>[:searchable, :displayable], :namespace_prefix=>nil)
    t.agreement_id(:path=>"agreementId", :index_as=>[:searchable, :displayable, :facetable, :sortable], :namespace_prefix=>nil)
    t.hypatia_source_id(:path=>"sourceId", :attributes=>{:source=>"hypatia"}, :index_as=>[:searchable,  :displayable, :sortable], :required=>:true, :namespace_prefix=>nil)
    t.object_creator(:path=>"objectCreator", :index_as=>[:searchable, :displayable], :required=>:true, :namespace_prefix=>nil)
    # note that naming the term object_id gives an error
    t.dor_object_id(:path=>"objectId", :index_as=>[:searchable, :displayable, :sortable],  :required=>:true, :namespace_prefix => nil )    
    t.object_label(:path=>"objectLabel", :index_as=>[:searchable, :displayable, :sortable],:required=>:true, :namespace_prefix=>nil)
    t.object_type(:path=>"objectType", :index_as=>[:searchable, :displayable, :facetable], :required=>:true, :namespace_prefix=>nil)
    t.set_type(:path=>"setType", :index_as=>[:searchable, :displayable, :facetable], :namespace_prefix=>nil)
    t.tag(:index_as=>[:searchable, :displayable, :facetable, :sortable], :required=>:true, :namespace_prefix=>nil)
    t.uuid(:path=>"otherId", :attributes=>{:name=>"uuid"}, :index_as=>[:searchable, :displayable, :sortable], :required=>:true, :namespace_prefix=>nil)
    
    # proxy declarations
    t.creator(:proxy=>[:object_creator])
    t.label(:proxy=>[:object_label])   
  end   # terminology
  
end   # class