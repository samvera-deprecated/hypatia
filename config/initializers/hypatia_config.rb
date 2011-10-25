# Hypatia overrides of blacklight_config.rb
Blacklight.configure(:shared) do |config|

  config[:default_solr_params] = {
    :qt => "search",
    :per_page => 10 
  }

  # solr field values given special treatment in the show (single result) view
  config[:show] = {
   :html_title => "title_t",
   :heading => "title_t",
   :display_type => "has_model_s"
  }

  # solr fld values given special treatment in the index (search results) view
  config[:index] = {
   :show_link => "title_facet",
   :num_per_page => 40,
   :record_display_type => "id"
  }

  # solr fields that will be treated as facets by the blacklight application
  #   The ordering of the field names is the order of the display
  config[:facet] = {
   :field_names => (facet_fields = [
     "repository_facet",
     "display_name_facet",
     "local_id_facet",
     "create_date_facet",
     "creator_facet",
     "filetype_facet",
     "topic_facet",
     "has_model_s"
     ]),
   :labels => {
     "repository_facet"=>"Repository",
     "display_name_facet"=>"Collection Title",
     "local_id_facet"=>"Call Number",
     "create_date_facet"=>"Date of Collections",
     "creator_facet"=>"Creator",
     "filetype_facet"=>"Filetype",
     "topic_facet"=>"Subject",
     "has_model_s"=>"Object Type"
   },

   :limits=> {nil=>10}
  }

  # Have BL send all facet field names to Solr. 
  config[:default_solr_params] ||= {}
  config[:default_solr_params][:"facet.field"] = facet_fields

  # "fielded" search configuration. Used by pulldown among other places.
  # For supported keys in hash, see rdoc for Blacklight::SearchFields
  config[:search_fields] ||= []
  config[:search_fields] << ['Descriptions', 'search']
#  config[:search_fields] << ['Descriptions and full text', 'fulltext']

  # "sort results by" select (pulldown)
  config[:sort_fields] ||= []
  config[:sort_fields] << ["relevance", "score desc"]
  config[:sort_fields] << ["title", "display_name_sort asc"]

  # number of facets to show before adding a more link
  config[:facet_more_num] = 5
  
  config[:featured_collections] = ["hypatia:gould_collection", "hypatia:creeley_collection"]
end