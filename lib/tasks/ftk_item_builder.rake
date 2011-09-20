require File.join(File.dirname(__FILE__), "/../../config/environment.rb")
require File.join(File.dirname(__FILE__), "/../ftk_item_assembler")
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/.."))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../../app/models"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../../vendor/plugins/hydra-head/lib/"))

# # FIXME: this will need a rewrite when the hydra head rake repo tasks are rewritten

namespace :hypatia do
  namespace :repo do

    desc "Delete a range of objects from Fedora and Solr. Example: 'rake hypatia:repo:delete[22, 50]' will delete hypatia:22 thru hypatia:50, inclusive"
    task :delete, [:first, :last] do |t, args|
      ENV["namespace"] = "hypatia"
      ENV["start"] = args[:first]
      ENV["stop"] = args[:last]
      Rake::Task["hydra:purge_range"].reenable
      Rake::Task["hydra:purge_range"].invoke
    end
    
    namespace :ftk_file_items do
      desc "Create ftk_item objects in Fedora (and Solr) from parent dir of 'FTK xml' and 'Display Derivatives' dirs. Example: 'rake hypatia:repo:ftk_file_items:build dir=/data_raw/Stanford/M1437\ Gould' " 
      task :build do
        if !ENV["dir"].nil? 
          parent_dir = ENV["dir"]
        else
          puts "You must specify the directory containing the FTK xml dirs, etc. Example: 'rake hypatia:repo:ftk_file_items:build dir=/data_raw/Stanford/M1437\ Gould' "
        end
        if !parent_dir.nil?
          ftk_xml_file_dir = parent_dir + "/FTK\ xml"
          ftk_report = ftk_xml_file_dir + "/Report.xml"
          display_derivative_dir = parent_dir + "/Display\ Derivatives"
          build_ftk_file_items(ftk_report, ftk_xml_file_dir, display_derivative_dir)
        end
      end

#      desc "delete a range of objects, then create the ftk file items per the directory indicated.  Example: 'rake hypatia:repo:ftk_file_items:refresh[22, 50] dir=/data_raw/Stanford/\"M1437\ Gould\"'"
#      task :refresh, :start_arg, :stop_arg => ["hypatia:repo:delete", :build]
    end # namespace :ftk_file_items

    namespace :disk_image_items do
      desc "Create disk_image_item objects in Fedora (and Solr) from parent dir of 'Disk Image' and 'Computer Media Photo' dirs. Example: 'rake hypatia:repo:disk_image_items:build dir=/data_raw/Stanford/M1292\ Xanadu' " 
      task :build do
        if !ENV["dir"].nil? 
          parent_dir = ENV["dir"]
        else
          puts "You must specify the directory containing the FTK disk image dirs, etc.  Example: 'rake hypatia:repo:disk_image_items:build dir=/data_raw/Stanford/M1292\ Xanadu' "
        end
        if !parent_dir.nil?
          disk_image_files_dir = parent_dir + "Disk\ Image" 
          computer_media_photos_dir = parent_dir + "Computer\ Media\ Photo"
          build_ftk_disk_items(disk_image_files_dir, computer_media_photos_dir)
        end
      end

#      desc "delete a range of objects, then create the disk image items per the directory indicated. Example: 'rake hypatia:repo:disk_image_items:refresh[22, 50] dir=/data_raw/Stanford/\"M1292\ Xanadu\"'"
#      task :refresh, :start_arg, :stop_arg => ["hypatia:repo:delete", :build]
    end # namespace :disk_items

    top_data_dir = "/data_raw/"

    namespace :gould do
      gould_dir = top_data_dir + "Stanford/M1437\ Gould"
      
      desc "Create Gould FTK Item objects in Fedora (and Solr).  Assumes data is in " + gould_dir
      task :build do
        ENV["dir"] = gould_dir
        Rake::Task["hypatia:repo:ftk_file_items:build"].reenable
        Rake::Task["hypatia:repo:ftk_file_items:build"].invoke
      end
      
#      desc "Delete Gould objects indicated by range, then create Gould FTK Item objects in Fedora (and Solr).  Example: 'rake hypatia:repo:gould:refresh[22, 50]' "
#      task :refresh, :start_arg, :stop_arg => ["hypatia:repo:delete", :build] 
    end # namespace :gould
    
  end # namespace :repo

end # namespace hypatia


#-------------- SUPPORTING METHODS -------------


# NAOMI_MUST_COMMENT_THIS_METHOD
def build_ftk_file_items(ftk_report, ftk_xml_file_dir, display_derivative_dir)
  # FIXME:  could rewrite the processing so it doesn't need RAILS environment:
  #   load foxml into fedora, then call Solrizer::Fedora::Solrizer.solrize(pid)
  f = FtkItemAssembler.new
  f.process(ftk_report, ftk_xml_file_dir, display_derivative_dir)
end

# NAOMI_MUST_COMMENT_THIS_METHOD
def build_ftk_disk_items(disk_image_files_dir, computer_media_photos_dir)
  # FIXME:  could rewrite the processing so it doesn't need RAILS environment:
  #   load foxml into fedora, then call Solrizer::Fedora::Solrizer.solrize(pid)
  assembler = FtkDiskImageItemAssembler.new(:disk_image_files_dir => disk_image_files_dir, :computer_media_photos_dir => computer_media_photos_dir)
  assembler.process
end
