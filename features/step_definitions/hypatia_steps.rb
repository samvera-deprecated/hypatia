require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^I (should|should not) see a link to the show page for "([^"]*)"$/ do |bool, object_id|
  path = "the show page for #{object_id}"
  if bool == "should"
    page.should have_xpath(".//a[@href=\"#{path_to(path)}\"]")
  else
    page.should_not have_xpath(".//a[@href=\"#{path_to(path)}\"]")
  end
end

Then /^I should see a link to the show page for "([^"]*)" with label "([^"]*)"$/ do |object_id, link_label|
  path = "the show page for #{object_id}"
  page.should have_xpath(".//a[@href=\"#{path_to(path)}\"]", :text=>link_label)  
end


# 'I should see "text"' step  with comment at end of line
Then /^I should see "(.*?)"(?: +\#.*)$/ do |text|
  text.gsub!(/\\"/, '"')  # text could have escaped quotes
  assert page.has_content?(text)
end

Then /^I (should|should not) see a link to datastream "([^"]*)" in FileAsset object "([^"]*)"$/ do |bool, ds_id, pid|
  path = "the download of #{ds_id} from asset #{pid}"
  if bool == "should"
    page.should have_xpath(".//a[@href=\"#{path_to(path)}\"]")
  else
    page.should_not have_xpath(".//a[@href=\"#{path_to(path)}\"]")
  end
end
