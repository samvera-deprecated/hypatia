require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^I should see a link to the show page for "([^"]*)"$/ do |object_id|
  path = "the show page for " + object_id
  page.should have_xpath(".//a[@href=\"#{path_to(path)}\"]")
end

Then /^I should not see a link to the show page for "([^"]*)"$/ do |object_id|
  path = "the show page for " + object_id
  page.should_not have_xpath(".//a[@href=\"#{path_to(path)}\"]")
end

# 'I should see "text"' step  with comment at end of line
Then /^I should see "(.*?)"(?: +\#.*)$/ do |text|
  text.gsub!(/\\"/, '"')  # text could have escaped quotes
  assert page.has_content?(text)
end
