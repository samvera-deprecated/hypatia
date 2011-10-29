require 'vendor/plugins/hydra-head/app/helpers/application_helper.rb'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # overridden for localization
  def application_name
    'Hypatia'
  end

  # display the Solr values populated per the datastream model with dt and dd html tags
  def display_ds_values_as_dl_element(dsid, solr_fld_sym, display_label)
    values = get_values_from_datastream(@document_fedora, dsid, [solr_fld_sym])
    unless values.first.empty?
      result = "<dt>#{display_label}</dt><dd>#{values.join(', ')}</dd>"
    end
    result 
  end
  
  # get the URL to retrieve the content of a DataStream as indicated in contentMetadata
  # @param [ActiveFedora::ContentModel] the fedora object with the contentMetadata
  # @param [Symbol or String] the filename (or filename field) in the contentMetadata -- id attribute of a <file> element
  # @param [Symbol] the OM term for the pid of the FileAsset Fedora object containing the datastream -- objectId attribute of <resource> element in contentMetadata
  # @param [Symbol] the OM term for the datastream id in the FileAsset Fedora object -- the contents of the <location> element with type attribute=datastreamId
  # @return a URL that will retrieve the content of the datastream in the FileAsset object.
  def get_datastream_url_from_content_md(fedora_obj, filename, file_asset_pid_fld, file_ds_id_fld)
    if filename.is_a?(Symbol)
      filename = get_values_from_datastream(fedora_obj, "contentMetadata", filename)
    end
    file_asset_pid = get_values_from_datastream(fedora_obj, "contentMetadata", file_asset_pid_fld)
    file_ds_id = get_values_from_datastream(fedora_obj, "contentMetadata", file_ds_id_fld).first
    asset_downloads_path(file_asset_pid, :download_id=>file_ds_id)
  end
  
  # return an image tag populated according to the contentMetadata in the fedora object and the symbol for the term for the specific <resource> element in the contentMetadata
  #  the filename of the image (used in :alt) is from the term [resource_ref_symbol, :file, :filename]
  # @param [ActiveFedora::ContentModel] the fedora object with the contentMetadata
  # @param [Symbol] the term assigned to the desired <resource> element (often chosen with the value of the type attribute, e.g.  t.dd(:ref=>:resource, :attributes=>{:type=>"media-file"}) )
  # @param [Hash] any additional args to be used in the image tag
  def get_image_tag_from_content_md(fedora_obj, resource_ref_symbol, addl_args)
    filename = get_values_from_datastream(fedora_obj, "contentMetadata", [resource_ref_symbol, :file, :filename])
    return "" if filename.to_s.blank?
    url = get_datastream_url_from_content_md(fedora_obj, filename, [resource_ref_symbol, :fedora_pid], [resource_ref_symbol, :file, :ds_id])
    addl_args[:alt] = filename
    image_tag(url, addl_args)
  end
  
  def get_image_tag_from_solr(doc,resource_ref_symbol, addl_args={})
    af_base = load_af_instance_from_solr(doc)
    the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first    
    obj = the_model.load_instance(doc[:id])
    get_image_tag_from_content_md(obj, resource_ref_symbol, addl_args)
  end
  
  def render_facet_value(facet_solr_field, item, options ={})
    if item.is_a? Array
      link_to_unless(options[:suppress_link], t(item[0], :default=>item[0]), add_facet_params_and_redirect(facet_solr_field, item[0]), :class=>"facet_select") + " (" + format_num(item[1]) + ")" 
    else
      link_to_unless(options[:suppress_link], t(item.value, :default=>item.value), add_facet_params_and_redirect(facet_solr_field, item.value), :class=>"facet_select") + " (" + format_num(item.hits) + ")" 
    end
  end
  
  def get_values_from_index(doc,field,options={})
    if doc.has_key?(field)
      if doc[field].is_a?(Array)
        return doc[field].join(options.has_key?(:delimiter) ? options[:delimiter] : ", ")
      else
        return doc[field]
      end
    end
  end
  
  def render_field_from_index(doc,field,label,options={})
    values = get_values_from_index(doc,field,options)
    return nil if values.nil?
    "<dt>#{label}</dt><dd>#{values}</dd>"
  end
  
  def get_members_from_solr(document)
    af_base = load_af_instance_from_solr(document)
    the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first    
    obj = the_model.load_instance(document[:id])
    return obj.members(:response_format=>:solr)
  end
  
  def get_parts_from_solr(document)
    af_base = load_af_instance_from_solr(document)
    the_model = ActiveFedora::ContentModel.known_models_for( af_base ).first    
    obj = the_model.load_instance(document[:id])
    return obj.parts(:response_format=>:solr)
  end
  
  def get_iamge_for_collection(document, opts={})
    img = ""
    get_parts_from_solr(document).hits.each do |hit|
      img = image_tag(asset_downloads_path(:asset_id=>hit["id"], :download_id=>"DS1"), opts) if hit["title_t"].to_s.match(/-thumb\.jpg$/)
    end
    return nil if img.blank?
    img
  end
  
  def get_file_attributes_from_fedora(asset_id)
    ds = FileAsset.load_instance(asset_id).datastreams
    return ds["DS1"].attributes if ds.has_key?("DS1")
  end
  
  def featured_collections
    response,docs = get_solr_response_for_field_values("id",Blacklight.config[:featured_collections], {:sort=>"title_sort desc"})
    return docs
  end
  
  # return an object's repository name as a string.  The repository name 
  #  comes from a HypatiaCollection object's descMetadata datastream
  # @param [ActiveFedora::ContentModel] the fedora object for the show view
  def get_repository_name(fedora_obj)
    return (get_coll_field_val(fedora_obj, :repository))
  end

  # return an object's collection's title as a string.  The collection title
  #  comes from a HypatiaCollection object's descMetadata datastream
  # @param [ActiveFedora::ContentModel] the fedora object for the show view
  def get_coll_title(fedora_obj)
    return (get_coll_field_val(fedora_obj, :title))
  end
  
  # return an object's (first) collection's (first) field value from the
  #  collection object's descMetadtata.  We go up the tree of sets until 
  #  we get to a HypatiaCollection object, then we get the field from that 
  #  collection object's descMetadata datastream.
  # @param [ActiveFedora::ContentModel] the fedora object for the show view
  # @return [String] value of field from ancestor collection object's descMetadata
  #  or an empty string if there is no value the ancestral chain of relationships
  #  ends without a HypatiaCollection object
  def get_coll_field_val(fedora_obj, desired_field)
    if (desired_field.is_a?(String))
      desired_field = desired_field.to_sym
    end
    if (fedora_obj.collections.size > 0)
      coll_obj = HypatiaCollection.load_instance(fedora_obj.collections[0].pid)
      return get_values_from_datastream(coll_obj, "descMetadata", desired_field).first
    elsif (fedora_obj.sets.size > 0)
      # we can load the parent object as a set because we are only going to check "collections" and "sets"
      return values = get_coll_field_val(HypatiaSet.load_instance(fedora_obj.sets[0].pid), desired_field)
    end
    return ""
  end
  
end
