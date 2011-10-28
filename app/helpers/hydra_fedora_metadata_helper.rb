require 'vendor/plugins/hydra-head/app/helpers/hydra_fedora_metadata_helper.rb'
module HydraFedoraMetadataHelper
  # just testing out if we can easily add a :disabled option
  def fedora_text_field(resource, datastream_name, field_key, opts={})
    field_name = field_name_for(field_key)
    field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
    field_values = [""] if field_values.empty?
    field_values = [field_values.first] unless opts.fetch(:multiple, true)
  
    required = opts.fetch(:required, true) ? "required" : ""
    disabled = opts.fetch(:disabled, false) ? "disabled" : ""
    
    body = ""
  
    field_values.each_with_index do |current_value, z|
      base_id = generate_base_id(field_name, current_value, field_values, opts)
      name = "asset[#{datastream_name}][#{field_name}][#{z}]"
        body << "<input class=\"editable-edit edit\" id=\"#{base_id}\" data-datastream-name=\"#{datastream_name}\" name=\"#{name}\" value=\"#{h(current_value.strip)}\" #{required unless z > 0} #{disabled} type=\"text\" />"
        body << "<a href=\"\" title=\"Delete '#{h(current_value)}'\" class=\"destructive field\">Delete</a>" if opts.fetch(:multiple, true) && !current_value.empty?
    end
  
    result = field_selectors_for(datastream_name, field_key)
    result << body
  
    return result
  end

end