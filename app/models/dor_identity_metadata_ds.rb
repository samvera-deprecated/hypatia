# defines the expected OM terminology for a DOR identityMetadata datastream
class DorIdentityMetadataDS < ActiveFedora::NokogiriDatastream 
  
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"identityMetadata", :xmlns => '')
    # in alphabetical order
    t.adminPolicy(:index_as=>[:searchable, :displayable, :facetable, :sortable], :required=>:false, :type=>:string, :namespace_prefix => nil )
    t.agreementId(:index_as=>[:searchable, :displayable, :facetable, :sortable],  :required=>:false, :type=>:string, :namespace_prefix => nil )  
    t.objectCreator(:index_as=>[:searchable, :displayable, :facetable, :sortable], :required=>:true, :type=>:string, :namespace_prefix => nil )
    t.objectId(:index_as=>[:searchable, :displayable, :sortable],  :required=>:true, :type=>:string, :namespace_prefix => nil )
    t.objectLabel(:index_as=>[:searchable, :displayable, :facetable, :sortable],  :required=>:true, :type=>:string, :namespace_prefix => nil )  
    t.objectType(:index_as=>[:searchable, :displayable, :facetable, :sortable],  :required=>:true, :type=>:string, :namespace_prefix => nil )  
    t.otherId(:index_as=>[:searchable,  :displayable, :facetable, :sortable], :attributes=>{:type=>"name"},  :required=>:true, :type=>:string, :namespace_prefix => nil )  
    t.setType(:index_as=>[:searchable, :displayable, :facetable, :sortable], :required=>:false, :type=>:string, :namespace_prefix => nil )
    t.sourceId(:index_as=>[:searchable,  :displayable, :facetable, :sortable], :attributes=>{:type=>"source"},  :required=>:true, :type=>:string, :namespace_prefix => nil )  
    t.tag(:index_as=>[:searchable, :displayable, :facetable, :sortable],  :required=>:true, :type=>:string, :namespace_prefix => nil )  
  end
  
end #class