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
    
    namespace :coll do

      # would be nice to simply load all foxml.xml objects or all hypatia_*_collection.foxml.xml in a directory??
      #   except also need pids for solrizing ...
      COLL_OBJS = {
        "hypatia_cheuse_collection.foxml.xml" => "hypatia:cheuse_collection",
        "hypatia_creeley_collection.foxml.xml" => "hypatia:creeley_collection",
        "hypatia_gallagher_collection.foxml.xml" => "hypatia:gallagher_collection",
        "hypatia_gould_collection.foxml.xml" => "hypatia:gould_collection",
        "hypatia_koch_collection.foxml.xml" => "hypatia:koch_collection",
        "hypatia_lmaf_collection.foxml.xml" => "hypatia:lmaf_collection",
        "hypatia_nhoa_collection.foxml.xml" => "hypatia:nhoa_collection",
        "hypatia_pelli_collection.foxml.xml" => "hypatia:pelli_collection",
        "hypatia_sha_collection.foxml.xml" => "hypatia:sha_collection",
        "hypatia_tobin_collection.foxml.xml" => "hypatia:tobin_collection",
        "hypatia_turner_collection.foxml.xml" => "hypatia:turner_collection",
        "hypatia_warner_collection.foxml.xml" => "hypatia:warner_collection",
        "hypatia_welch_collection.foxml.xml" => "hypatia:welch_collection",
        "hypatia_xanadu_collection.foxml.xml" => "hypatia:xanadu_collection",
      }

      desc "Load all collection objects"
      task :load => :environment do
        if !ENV["dir"].nil? 
          directory = ENV["dir"]
        else
          puts "You must specify the directory containing the Hypatia collection objects.  Example: rake hypatia:load:coll_objs dir=/data_raw/hypatia_coll_objs/foxml"
        end

        if !directory.nil?
          COLL_OBJS.each { |fname, pid|
            filename = File.join("#{directory}", "#{fname}")
            load_foxml(filename, pid)
          }
        end
      end

      desc "Delete all collection objects"
      task :delete => :environment do
        delete_all(COLL_OBJS.values)
      end

      desc "Refresh all collection objects"
      task :refresh => [:delete, :load]
    end # namespace collection

    namespace :ftk_file_items do
      desc "Create HypatiaFtkItem objects. Require args coll_pid, dir:  coll_pid='hypatia:gould_collection' dir=/data_raw/Stanford/M1437\ Gould' " 
      task :build => :environment do
        if !ENV["dir"].nil? 
          parent_dir = ENV["dir"]
        end
        if !ENV["coll_pid"].nil? 
          coll_pid = ENV["coll_pid"]
        end
        if (coll_pid.nil? || coll_pid.size == 0 || parent_dir.nil? || parent_dir.size == 0)
          puts "You must specify the collection pid and the directory containing the 'FTK xml' and 'Display Derivatives' dirs.  Example: 'rake hypatia:repo:ftk_file_items:build coll_pid='hypatia:gould_collection' dir=/data_raw/Stanford/M1437\ Gould' "
        else
          ftk_xml_file_dir = parent_dir + "/FTK\ xml"
          ftk_report = ftk_xml_file_dir + "/Report.xml"
          display_derivative_dir = parent_dir + "/Display\ Derivatives"
          build_ftk_file_items(coll_pid, ftk_report, ftk_xml_file_dir, display_derivative_dir)
        end
      end
      
#      use 'task :t, [args] => [deps]' 
#      desc "delete a range of objects, then create the ftk file items per the directory indicated.  Example: 'rake hypatia:repo:ftk_file_items:refresh[22, 50] dir=/data_raw/Stanford/\"M1437\ Gould\"'"
#      task :refresh, [:first, :last] => ["hypatia:repo:delete", :build]
    end # namespace :ftk_file_items

    namespace :disk_image_items do
      desc "Create HypatiaDiskImageItem objects. Requires args coll_pid, dir:  pid='hypatia:xanadu_collection' dir=/data_raw/Stanford/M1292\ Xanadu' " 
      task :build => :environment do
        if !ENV["dir"].nil? 
          parent_dir = ENV["dir"]
        end
        if !ENV["coll_pid"].nil? 
          coll_pid = ENV["coll_pid"]
        end
        if (coll_pid.nil? || coll_pid.size == 0 || parent_dir.nil? || parent_dir.size == 0)
          puts "You must specify the collection pid and the directory containing the disk image dirs, etc.  Example: 'rake hypatia:repo:disk_image_items:build coll_pid='hypatia:xanadu_collection' dir=/data_raw/Stanford/M1292\ Xanadu' "
        else
          disk_image_files_dir = parent_dir + "/Disk\ Image" 
          computer_media_photos_dir = parent_dir + "/Computer\ Media\ Photo"
          build_ftk_disk_items(coll_pid, disk_image_files_dir, computer_media_photos_dir)
        end
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

      desc "Create Gould File Item objects.  Assumes data is in #{gould_dir}"
      task :build_files do
        ENV["coll_pid"] = gould_coll_pid
        ENV["dir"] = gould_dir
        Rake::Task["hypatia:repo:ftk_file_items:build"].reenable
        Rake::Task["hypatia:repo:ftk_file_items:build"].invoke
      end
      
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
      desc "Create Tobin DiskImageItem objects" 
      task :build_disks do
        tobin_coll_pid = "hypatia:tobin_collection"
        tobin_dir = top_data_dir + "Yale/mssa.ms.1746/data/"
        build_ftk_disk_items(tobin_coll_pid, tobin_dir, tobin_dir)
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

# build hypatia_ftk_item objects in Fedora (and Solr) indicated by Rails environment
# @param [String] pid of collection object to "contain" these disk image items
# @param [String] path to FTK's Report.xml file
# @param [String] path to directory containing FTK files (usually .../FTK xml)
# @param [String] path to directory containing FTK created display derivatives
def build_ftk_file_items(coll_pid, ftk_report, ftk_xml_file_dir, display_derivative_dir)
  assembler = FtkItemAssembler.new(:collection_pid => coll_pid)
  assembler.process(ftk_report, ftk_xml_file_dir, display_derivative_dir)
end

# build hypatia_disk_image objects in Fedora (and Solr) indicated by Rails environment
# @param [String] pid of collection object to "contain" these disk image items
# @param [String] path to directory containing disk image files
# @param [String] path to directory containing photos of the computer media
def build_ftk_disk_items(coll_pid, disk_image_files_dir, computer_media_photos_dir)
  assembler = FtkDiskImageItemAssembler.new(:collection_pid => coll_pid, :disk_image_files_dir => disk_image_files_dir, :computer_media_photos_dir => computer_media_photos_dir)
  assembler.process
end
