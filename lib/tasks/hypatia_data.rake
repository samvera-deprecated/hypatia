# FIXME: this will need a rewrite when the hydra head rake repo tasks are rewritten

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
    
    top_data_dir = "/data_raw/"

    namespace :ftk_file_items do
# FIXME: needs to get collection_pid as argument
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

#      use 'task :t, [args] => [deps]' 
#      desc "delete a range of objects, then create the ftk file items per the directory indicated.  Example: 'rake hypatia:repo:ftk_file_items:refresh[22, 50] dir=/data_raw/Stanford/\"M1437\ Gould\"'"
#      task :refresh, [:first, :last] => ["hypatia:repo:delete", :build]
    end # namespace :ftk_file_items

    namespace :disk_image_items do
      desc "Create HypatiaDiskImageItem objects. Example: 'rake hypatia:repo:disk_image_items:build pid='hypatia:xanadu_collection' dir=/data_raw/Stanford/M1292\ Xanadu' " 
      task :build do
        if !ENV["dir"].nil? 
          parent_dir = ENV["dir"]
        end
        if !ENV["coll_pid"].nil? 
          collection_pid = ENV["coll_pid"]
        end
        if (collection_pid.nil? || collection_pid.size == 0 || parent_dir.nil? || parent_dir.size == 0)
          puts "You must specify the collection pid and the directory containing the disk image dirs, etc.  Example: 'rake hypatia:repo:disk_image_items:build coll_pid='hypatia:xanadu_collection' dir=/data_raw/Stanford/M1292\ Xanadu' "
        else
          disk_image_files_dir = parent_dir + "/Disk\ Image" 
          computer_media_photos_dir = parent_dir + "/Computer\ Media\ Photo"
          build_ftk_disk_items(collection_pid, disk_image_files_dir, computer_media_photos_dir)
        end
      end
      
      desc "Create Cheuse DiskImageItem objects"
      task :cheuse => ["hypatia:repo:cheuse:build_disks"] do
      end

      desc "Create Creeley DiskImageItem objects"
      task :creeley => ["hypatia:repo:creeley:build_disks"] do
      end

      desc "Create Gould DiskImageItem objects"
      task :gould => ["hypatia:repo:gould:build_disks"] do
      end

      desc "Create Koch DiskImageItem objects"
      task :koch => ["hypatia:repo:koch:build_disks"] do
      end

      desc "Create Koch DiskImageItem objects"
      task :tobin => ["hypatia:repo:tobin:build_disks"] do
      end

      desc "Create Xanadu DiskImageItem objects"
      task :xanadu => ["hypatia:repo:xanadu:build_disks"] do
      end

#      desc "delete a range of objects, then create the disk image items per the directory indicated. Example: 'rake hypatia:repo:disk_image_items:refresh[22, 50] dir=/data_raw/Stanford/\"M1292\ Xanadu\"'"
#      task :refresh, [:first, :last] => ["hypatia:repo:delete", :build]
    end # namespace :disk_items

    namespace :cheuse do
      desc "Create Cheuse DiskImageItem objects.  Assumes data is in /data_raw/Virginia ..." 
      task :build_disks do
        cheuse_coll_pid = "hypatia:cheuse_collection"
        parent_dir = top_data_dir + "Virginia/oldFiles/"
        cheuse_disk_image_files_dir = parent_dir + "diskImages" 
        cheuse_photos_dir = parent_dir + "photos"
        build_ftk_disk_items(cheuse_coll_pid, cheuse_disk_image_files_dir, cheuse_photos_dir)
      end
    end
    
    namespace :creeley do
      creeley_dir = top_data_dir + "Stanford/M0662\ Creeley"
      creeley_coll_pid = "hypatia:creeley_collection"
      
      desc "Create Creeley DiskImageItem objects.  Assumes data is in #{creeley_dir}" 
      task :build_disks do
        ENV["coll_pid"] = creeley_coll_pid
        ENV["dir"] = creeley_dir
        Rake::Task["hypatia:repo:disk_image_items:build"].reenable
        Rake::Task["hypatia:repo:disk_image_items:build"].invoke
      end
    end

    namespace :gould do
      gould_dir = top_data_dir + "Stanford/M1437\ Gould"
      gould_coll_pid = "hypatia:gould_collection"
      
      desc "Create Gould DiskImageItem objects.  Assumes data is in #{gould_dir}" 
      task :build_disks do
        ENV["coll_pid"] = gould_coll_pid
        ENV["dir"] = gould_dir
        Rake::Task["hypatia:repo:disk_image_items:build"].reenable
        Rake::Task["hypatia:repo:disk_image_items:build"].invoke
      end

#      desc "Create Gould File Item objects.  Assumes data is in #{gould_dir}"
#      task :build_files do
#        ENV["coll_pid"] = gould_coll_pid
#        ENV["dir"] = gould_dir
#        Rake::Task["hypatia:repo:ftk_file_items:build"].reenable
#        Rake::Task["hypatia:repo:ftk_file_items:build"].invoke
#      end
      
#      desc "Delete Gould objects indicated by range, then create Gould FTK Item objects in Fedora (and Solr).  Example: 'rake hypatia:repo:gould:refresh[22, 50]' "
#      task :refresh, [:first, :last] => ["hypatia:repo:delete", :build_disks, :build_files] 
    end # namespace :gould
     
    namespace :koch do
      koch_dir = top_data_dir + "Stanford/M1584\ Koch"
      koch_coll_pid = "hypatia:koch_collection"
      
      desc "Create Koch DiskImageItem objects.  Assumes data is in #{koch_dir}" 
      task :build_disks do
        ENV["coll_pid"] = koch_coll_pid
        ENV["dir"] = koch_dir
        Rake::Task["hypatia:repo:disk_image_items:build"].reenable
        Rake::Task["hypatia:repo:disk_image_items:build"].invoke
      end
    end
    
    namespace :tobin do
      tobin_dir = top_data_dir + "Yale/mssa.ms.1746/data/"
      tobin_coll_pid = "hypatia:tobin_collection"
      
      desc "Create Tobin DiskImageItem objects.  Assumes data is in #{tobin_dir}" 
      task :build_disks do
        ENV["coll_pid"] = tobin_coll_pid
        ENV["dir"] = tobin_dir
        Rake::Task["hypatia:repo:disk_image_items:build"].reenable
        Rake::Task["hypatia:repo:disk_image_items:build"].invoke
      end
    end
    
    namespace :xanadu do
      xanadu_dir = top_data_dir + "Stanford/M1292\ Xanadu"
      xanadu_coll_pid = "hypatia:xanadu_collection"
      
      desc "Create Xanadu DiskImageItem objects.  Assumes data is in #{xanadu_dir}"
      task :build_disks do
        ENV["coll_pid"] = xanadu_coll_pid
        ENV["dir"] = xanadu_dir
        Rake::Task["hypatia:repo:disk_image_items:build"].reenable
        Rake::Task["hypatia:repo:disk_image_items:build"].invoke
      end
    end # namespace :xanadu

  end # namespace :repo

end # namespace hypatia


#-------------- SUPPORTING METHODS -------------


# FIXME: needs to get collection_pid as argument

# build hypatia_ftk_item objects in Fedora (and Solr) indicated by Rails environment
# @param [String] path to FTK's Report.xml file
# @param [String] path to directory containing FTK files (usually .../FTK xml)
# @param [String] path to directory containing FTK created display derivatives
def build_ftk_file_items(ftk_report, ftk_xml_file_dir, display_derivative_dir)
  # FIXME:  could rewrite the processing so it doesn't need RAILS environment:
  #   load foxml into fedora, then call Solrizer::Fedora::Solrizer.solrize(pid)
  f = FtkItemAssembler.new
#  f.collection_pid = coll_pid
  f.process(ftk_report, ftk_xml_file_dir, display_derivative_dir)
end

# build hypatia_disk_image objects in Fedora (and Solr) indicated by Rails environment
# @param [String] pid of collection object to "contain" these disk image items
# @param [String] path to directory containing disk image files
# @param [String] path to directory containing photos of the computer media
def build_ftk_disk_items(collection_pid, disk_image_files_dir, computer_media_photos_dir)
  # FIXME:  could rewrite the processing so it doesn't need RAILS environment:
  #   load foxml into fedora, then call Solrizer::Fedora::Solrizer.solrize(pid)
  assembler = FtkDiskImageItemAssembler.new(:collection_pid => collection_pid, :disk_image_files_dir => disk_image_files_dir, :computer_media_photos_dir => computer_media_photos_dir)
  assembler.process
end
