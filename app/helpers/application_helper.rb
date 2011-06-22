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
  
  # display the Solr values populated per the datastream model within <div><dl> html tags
  def display_ds_values_in_div_dl(dsid, solr_fld_sym, display_label, div_class=dsid)
    values = get_values_from_datastream(@document_fedora, dsid, [solr_fld_sym])
    unless values.first.empty?
      result = "<div class=\"#{div_class}\"><dl><dt>#{display_label}</dt><dd>#{values.join(', ')}</dd></dl></div>"
    end
    result 
    
  end
  
end
