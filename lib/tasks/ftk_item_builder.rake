require 'spec/rake/spectask'
require "cucumber/rake/task"
require File.join(File.dirname(__FILE__), "/../../config/environment.rb")
require File.join(File.dirname(__FILE__), "/../ftk_item_assembler")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/.."))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../../app/models"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../../vendor/plugins/hydra-head/lib/"))


# number of seconds to pause after issuing commands to return a git repos to it's pristine state (e.g. make jetty squeaky clean)
GIT_RESET_WAIT = 7

namespace :hypatia do
  namespace :gould do
      desc "Build ftk objects"
      task :build_ftk_file_items do   
        f = FtkItemAssembler.new
        gould_report = "/usr/local/projects/hypatia_data/Stanford/M1437\ Gould/FTK\ xml/Report.xml"
        file_dir = "/usr/local/projects/hypatia_data/Stanford/M1437\ Gould/FTK\ xml/"
        display_derivative_dir = "/usr/local/projects/hypatia_data/Stanford/M1437\ Gould/Display\ Derivatives"
        f.process(gould_report,file_dir,display_derivative_dir)
      end
  
      desc "Build disk objects"
      task :build_ftk_disk_items do  
        disk_image_files_dir = "/usr/local/projects/hypatia_data/Stanford/M1437\ Gould/Disk\ Image" 
        computer_media_photos_dir = "/usr/local/projects/hypatia_data/Stanford/M1437\ Gould/Computer\ Media\ Photo" 
        assembler = FtkDiskImageItemAssembler.new(:disk_image_files_dir => disk_image_files_dir, :computer_media_photos_dir => computer_media_photos_dir)
        assembler.process
      end
  end
end

# copy down the data from sul-brick & point this task at it