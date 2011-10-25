require_dependency( 'vendor/plugins/hydra-head/app/controllers/catalog_controller.rb' )

class CatalogController < ApplicationController
  
  helper :all # include all helpers, all the time
  
  before_filter :requirements, :only => [:edit_members,:add_relationships]
  
  def edit_members
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
  
  def update_members
    status_text = ""
    parent_doc = load_fedora_doc_from_id(params[:id])
    relationship = parent_doc.is_a?(HypatiaCollection) ? :is_member_of_collection : :is_member_of
    child_ids = params[:child_ids] || []
    remove_ids = parent_doc.members_ids - child_ids
    child_ids.each do |cid|
      unless parent_doc.members_ids.include?(cid) #don't add a relationship if we already have one.
        child = load_fedora_doc_from_id(cid)
        child.add_relationship(relationship,params[:id])
        status_text << "Added #{relationship} relationship of #{cid} to #{params[:id]}"
        child.save
      end
    end
    remove_ids.each do |cid|
      child = load_fedora_doc_from_id(cid)
      child.remove_relationship(relationship,params[:id])
      status_text << "Removed #{relationship} relationship of #{cid} to #{params[:id]}"
      child.save
    end

    render :text => status_text
  end
  
  protected
  
  def requirements
    require_solr
    require_fedora
  end
  
  def load_fedora_doc_from_id(id)
    af_base = ActiveFedora::Base.load_instance(id)
    the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first
    if the_model.nil?
      the_model = DcDocument
    end
    return the_model.load_instance(id)
  end
end