require 'spec/rake/spectask'
require "cucumber/rake/task"
require File.join(File.dirname(__FILE__), "/../ftk_item_assembler")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/.."))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../../vendor/plugins/hydra-head/lib/"))


# number of seconds to pause after issuing commands to return a git repos to it's pristine state (e.g. make jetty squeaky clean)
GIT_RESET_WAIT = 7

namespace :hypatia do
  namespace :gould do
      desc "Build ftk objects"
      task :build_ftk_items do   
        f = FtkItemAssembler.new
        gould_report = File.join(File.dirname(__FILE__), "/../../spec/fixtures/ftk/Gould_FTK_Report.xml")
        file_dir = File.join(File.dirname(__FILE__), "/../../spec/fixtures/ftk/files")
        f.process(gould_report,file_dir)
      end
  
      desc "Build fake item"
      task :build_fake do
        f = FtkItemBuilder.new
      end
  end
end

# copy down the data from sul-brick & point this task at it