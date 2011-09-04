require 'spec/rake/spectask'
require "cucumber/rake/task"
require File.join(File.dirname(__FILE__), "/../ftk_item_builder")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/.."))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../../vendor/plugins/hydra-head/lib/"))


# number of seconds to pause after issuing commands to return a git repos to it's pristine state (e.g. make jetty squeaky clean)
GIT_RESET_WAIT = 7

namespace :hypatia do

  desc "Build ftk objects"
  task :build_items do   
    f = FtkItemBuilder.new

  end
end