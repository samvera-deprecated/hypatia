# just grabbing a bunch of useful step definitions from hydra-head plugin
require "vendor/plugins/hydra-head/features/step_definitions/html_validity_steps"
require "vendor/plugins/hydra-head/features/step_definitions/user_steps"
require "vendor/plugins/hydra-head/features/step_definitions/show_document_steps"

Given /^I (?:am )?log(?:ged)? in as the "([^\"]*)" user$/ do |login|
  email = "#{login}@#{login}.com"
  # Given %{a User exists with a Login of "#{login}"}
  user = User.create(:login => login, :email => email, :password => "password", :password_confirmation => "password")
  User.find_by_login(login).should_not be_nil
  visit logout_path
  visit login_path
  fill_in "Login", :with => login
  fill_in "Password", :with => "password"
  click_button "Login"
  Then %{I should see "#{login}"} 
  And %{I should see "Log Out"} 
end