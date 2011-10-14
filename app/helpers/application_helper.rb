require 'vendor/plugins/hydra-head/app/helpers/application_helper.rb'
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # overridden for localization
  def application_name
    'Hypatia'
  end
  
  # display the Solr values populated per the datastream model within a fieldset html tag
  #  this is a local helper method created to avoid all the repeated stuff in hydra-head/app/views/mods_assets/_show_description.html.erb
  def display_ds_values_as_fieldset(dsid, solr_fld_sym, display_label)
    values = get_values_from_datastream(@document_fedora, dsid, [solr_fld_sym])
    unless values.first.empty?
      result = "<fieldset><legend>#{display_label}</legend><div class=\"browse_value\">#{values.join(', ')}</div></fieldset>"
    end
    result 
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
    url = get_datastream_url_from_content_md(fedora_obj, filename, [resource_ref_symbol, :fedora_pid], [resource_ref_symbol, :file, :ds_id])
    addl_args[:alt] = filename
    image_tag(url, addl_args)
  end
  
  def render_facet_value(facet_solr_field, item, options ={})
    if item.is_a? Array
      link_to_unless(options[:suppress_link], t(item[0], :default=>item[0]), add_facet_params_and_redirect(facet_solr_field, item[0]), :class=>"facet_select") + " (" + format_num(item[1]) + ")" 
    else
      link_to_unless(options[:suppress_link], t(item.value, :default=>item.value), add_facet_params_and_redirect(facet_solr_field, item.value), :class=>"facet_select") + " (" + format_num(item.hits) + ")" 
    end
  end
end
