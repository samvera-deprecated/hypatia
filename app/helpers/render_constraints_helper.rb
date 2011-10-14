require_dependency 'vendor/plugins/blacklight/app/helpers/render_constraints_helper.rb'
module RenderConstraintsHelper

  def render_constraints_filters(localized_params = params)
     return "".html_safe unless localized_params[:f]
     content = ""
     localized_params[:f].each_pair do |facet,values|
        values.each do |val|
           content << render_constraint_element( facet_field_labels[facet],
                  t(val,:default=>val), 
                  :remove => catalog_index_path(remove_facet_params(facet, val, localized_params)),
                  :classes => ["filter", "filter-" + facet.parameterize] 
                ) + "\n"                 					            
  			end
     end 

     return content.html_safe    
  end

end