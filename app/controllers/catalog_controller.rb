require_dependency( 'vendor/plugins/hydra-head/app/controllers/catalog_controller.rb' )

class CatalogController < ApplicationController
  
  helper :all # include all helpers, all the time
  
  def edit_members
    require_solr
    require_fedora
    af_base = ActiveFedora::Base.load_instance(params[:id])
    the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first
    if the_model.nil?
      the_model = DcDocument
    end
    
    @document_fedora = the_model.load_instance(params[:id])
    q = build_lucene_query("\" AND NOT _query_:\"info\\\\:fedora/afmodel\\\\:HypatiaCollection")
    @response, @document_list = get_search_results(:q => q)
    @folder_response, @folder_list = get_solr_response_for_field_values("id",session[:folder_document_ids] || [])
  end
  
end