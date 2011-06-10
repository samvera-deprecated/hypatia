require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../app/helpers/infusion_view_helper'
# Here's the helper file we need
require 'action_view/helpers/javascript_helper'
require 'action_view/helpers/asset_tag_helper'
require 'action_controller'
#require 'action_view/helpers/asset_tag_helper'

class InfusionViewHelperTest < Test::Unit::TestCase
  
  # ActionView::Base.send(:include, InfusionViewHelper)
  # include InfusionViewHelper
  #   
  # def setup
  #   @view = ActionView::Base.new
  # end
  # 
  # def test_infusion_javascripts_returns_desired_include_tags
  #   assert_equal "", infusion_javascripts
  #   assert_equal "", infusion_javascripts(:uploader)
  #   assert_equal "", infusion_javascripts(:cache=>true)
  #   assert_equal "", infusion_javascripts(:uploader, :include_base=>false)
  # end
  # 
  # 
  # def test_infusion_stylesheets_returns_desired_link_tags
  #   assert_equal "", infusion_stylesheets
  #   assert_equal "", infusion_stylesheets(:uploader)
  #   assert_equal "", infusion_stylesheets(:cache=>true)
  #   assert_equal "", infusion_stylesheets(:uploader, :include_base=>false)
  # end

end