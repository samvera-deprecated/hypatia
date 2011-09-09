require_dependency( 'vendor/plugins/hydra-head/app/controllers/application_controller.rb')
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :inject_assets
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  protected
  
  def inject_assets
    stylesheet_links << ["http://fonts.googleapis.com/css?family=Copse|Open+Sans:300,400,600|Lato:700", "hypatia", {:media=>"all"}]
  end
end
