require 'spec/rake/spectask'
require "cucumber/rake/task"

# number of seconds to pause after issuing commands to return a git repos to its pristine state (e.g. make jetty squeaky clean)
GIT_RESET_WAIT = 7

namespace :hypatia do

  desc "Execute Continuous Integration build (docs, tests with coverage)"
  task :ci do   
    Rake::Task["hypatia:doc"].invoke
    Rake::Task["hypatia:db:test:reset"].invoke
    Rake::Task["hypatia:jetty:test:reset_then_config"].invoke

    require 'jettywrapper'
    jetty_params = {
      :jetty_home => File.expand_path(File.dirname(__FILE__) + '/../../jetty'),
      :quiet => false,
      :jetty_port => 8983,
      :solr_home => File.expand_path(File.dirname(__FILE__) + '/../../jetty/solr'),
      :fedora_home => File.expand_path(File.dirname(__FILE__) + '/../../jetty/fedora/default'),
      :startup_wait => 30
      }
    
# FIXME:  does this make jetty run in TEST environment???
    error = Jettywrapper.wrap(jetty_params) do
      Rake::Task["hypatia:spec"].invoke
      Rake::Task["hypatia:cucumber:fixtures_then_run"].invoke
    end
    raise "test failures: #{error}" if error

  end

#============= TESTING TASKS (SPECS, FEATURES) ================

  desc "Run the hypatia specs.  Must have jetty already running and fixtures loaded."
  Spec::Rake::SpecTask.new(:spec) do |t|
#     t.spec_opts = ['--options', "/spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end


  desc "Easieset way to run cucumber features. (Re)loads fixtures and runs cucumber tests.  Must have jetty already running."
  task :cucumber => "cucumber:fixtures_then_run"

  namespace :cucumber do
# NOTE: features fail if test solr is empty. - must load features fresh first (?)
    desc "Run cucumber features for hypatia. Must have jetty already running and fixtures loaded."
    task :run do
      puts %x[cucumber --color --format progress features]
      raise "Cucumber tests failed" unless $?.success?
    end

    desc "(Re)loads fixtures, then runs cucumber features.  Must have jetty already running."
    task :fixtures_then_run do
      system("rake hypatia:fixtures:refresh environment=test")
      Rake::Task["hypatia:cucumber:run"].invoke
    end    

  end # hypatia:cucumber namespace

#============= JETTY TASKS ================
  namespace :jetty do
    
    desc "return a jetty instance to its pristine state, then load our Solr and Fedora config files - takes 'test' as an arg, o.w. resets development jetty"
    task :reset_then_config, :env do |t, args|
      if args.env && args.env.downcase == "test"
        Rake::Task["hypatia:jetty:test:reset_then_config"].invoke
      else
        Rake::Task["hypatia:jetty:dev:reset_then_config"].invoke
      end
    end
    
    desc "return a jetty to its pristine state, as pulled from git - takes 'test' as an arg, o.w. resets development jetty"
    task :reset, :env  do |t, args|
      if args.env && args.env.downcase == "test"
        Rake::Task["hypatia:jetty:test:reset"].invoke
      else
        Rake::Task["hypatia:jetty:dev:reset"].invoke
      end
    end

# FIXME: !!!!!!!!!!! use separate jetty for test and for dev
    
    namespace :test do
      desc "return test jetty to its pristine state, as pulled from git"
      task :reset do
        system("cd jetty && git reset --hard HEAD && git clean -dfx & cd ..")
        sleep GIT_RESET_WAIT
      end
      
      desc "return test jetty to its pristine state, then load our Solr and Fedora config files"
      task :reset_then_config do
        Rake::Task["hypatia:jetty:test:reset"].invoke
        Rake::Task["hydra:jetty:config"].invoke
      end
    end # namespace hypatia:jetty:test

    namespace :dev do
      desc "return development jetty to its pristine state, as pulled from git"
      task :reset do
        system("cd jetty && git reset --hard HEAD && git clean -dfx & cd ..")
        sleep GIT_RESET_WAIT
      end

      desc "return development jetty to its pristine state, then load our Solr and Fedora config files"
      task :reset_then_config do
        Rake::Task["hypatia:jetty:dev:reset"].invoke
        Rake::Task["hydra:jetty:config"].invoke
      end
    end # namespace hypatia:jetty:dev
        
  end # namespace hypatia:jetty

#============= DATA (NON-FIXTURE) TASKS ================
  namespace :data do
    namespace :coll do
      
      # FIXME:  should perhaps just grab all foxml.xml objects or all hypatia_*_collection.foxml.xml in a directory??
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
      task :load do
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
      task :delete do
        delete_all(COLL_OBJS.values)
      end
      
      desc "Refresh all collection objects"
      task :refresh => [:delete, :load]
    end # namespace hypatia:data:collection
    
  end # namespace hypatia:data

#============= FIXTURE TASKS ================
  namespace :fixtures do
    
    desc "Load all Hypatia fixtures"
    task :load => ['ftk:load', 'noname:load'] 

    desc "Remove all Hypatia fixtures"
    task :delete => ['ftk:delete', 'noname:delete']

    desc "Remove then load all Hypatia fixtures"
    task :refresh => ['ftk:refresh', 'noname:refresh'] 

    namespace :ftk do
      FTK_FIXTURE_PIDS = [
        "hypatia:fixture_ftk_txt_item",
        "hypatia:fixture_ftk_wp6_item",
        "hypatia:fixture_ftk_unknown_item",
        "hypatia:fixture_ftk_file_factory",
        "hypatia:fixture_ftk_item_factory"
      ]
    
      desc "Load Hypatia FTK fixtures"
      task :load do
        # pids are converted to file names by substituting : for _
        load_fixtures(FTK_FIXTURE_PIDS)
      end

      desc "Remove Hypatia FTK fixtures"
      task :delete do
        delete_all(FTK_FIXTURE_PIDS)
      end

      desc "Remove then load Hypatia FTK fixtures"
      task :refresh do
        refresh_fixtures(FTK_FIXTURE_PIDS)
      end
    end # hypatia:fixtures:ftk namespace

    namespace :noname do
      NONAME_FIXTURE_PIDS = [
        "hypatia:fixture_coll",
        "hypatia:fixture_intermed1",
        "hypatia:fixture_intermed2",
        "hypatia:fixture_intermed3",
        "hypatia:fixture_item1",
        "hypatia:fixture_item2",
        "hypatia:fixture_item3",
        
        "hypatia:fixture_coll2",
        "hypatia:fixture_file_asset_ead_for_coll",
        "hypatia:fixture_file_asset_image_for_coll",

        "hypatia:fixture_media_item",
        "hypatia:fixture_file_asset_dd_for_media_item",
        "hypatia:fixture_file_asset_image1_for_media_item",
        "hypatia:fixture_file_asset_image2_for_media_item",
        
        "hypatia:fixture_ftk_file_item",
        "hypatia:fixture_file_asset_for_ftk_file_item",
      ]

      desc "Load Hypatia No Name fixtures"
      task :load do
        # pids are converted to file names by substituting : for _
        load_fixtures(NONAME_FIXTURE_PIDS)
      end

      desc "Remove Hypatia No Name fixtures"
      task :delete do
        delete_all(NONAME_FIXTURE_PIDS)
      end

      desc "Remove then load Hypatia No Name fixtures"
      task :refresh do
        refresh_fixtures(NONAME_FIXTURE_PIDS)
      end
    end # hypatia:fixtures:noname namespace

  end # hypatia:fixtures namespace


#============= DATABASE TASKS ================
  namespace :db do 
    namespace :test do 
      desc "Recreate test databases from scratch"
      task :reset do 
        old_env = RAILS_ENV # just in case
        RAILS_ENV = "test"
        Rake::Task['db:drop'].invoke
        Rake::Task['db:migrate'].invoke
        RAILS_ENV = old_env  # be safe
      end
    end
  end

#============= DOC TASKS ================
  # :doc task  using yard
  begin
    require 'yard'
    require 'yard/rake/yardoc_task'
    project_root = File.expand_path("#{File.dirname(__FILE__)}/../../")
    doc_destination = File.join(project_root, 'doc')
    if !File.exists?(doc_destination) 
      FileUtils.mkdir_p(doc_destination)
    end

    YARD::Rake::YardocTask.new(:doc) do |yt|
      readme_filename = 'README.textile'
      textile_docs = []
      Dir[File.join(project_root, "*.textile")].each_with_index do |f, index| 
        unless f.include?("/#{readme_filename}") # Skip readme, which is already built by the --readme option
          textile_docs << '-'
          textile_docs << f
        end
      end
      yt.files   = Dir.glob(File.join(project_root, '*.rb')) + 
                   Dir.glob(File.join(project_root, 'app', '**', '*.rb')) + 
                   Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + 
                   textile_docs
      yt.options = ['--output-dir', doc_destination, '--readme', readme_filename]
    end
  rescue LoadError
    desc "Generate YARD Documentation"
    task :doc do
      abort "Please install the YARD gem to generate rdoc."
    end
  end # doc task

end # hypatia namespace


#-------------- SUPPORTING METHODS -------------

# load a Fedora object from foxml, putting it in Fedora and indexing it into
# Solr
def load_foxml(file, pid)
  ENV["fixture"] = file
  Rake::Task["hydra:import_fixture"].reenable
  Rake::Task["hydra:import_fixture"].invoke  
  
  # we do this because hydra:import_fixture task is written so a provided PID
  #  implies a fixture in spec/fixtures, and a provided fixture file 
  #  implies no solr indexing.  Harrumph.
  if !pid.nil?
    solrizer = Solrizer::Fedora::Solrizer.new 
    solrizer.solrize(pid) 
  end 
end

# load all the fixtures in the passed array of fixture pids
#   pid is converted to file name by substituting : for _
def load_fixtures(fixture_pids)
  fixture_pids.each { |f|  
    load_fixture(f) 
  }
end

# load a fixture object
#   pid is converted to file name by substituting : for _
def load_fixture(fixture_pid)
  ENV["fixture"] = nil
  ENV["pid"] = fixture_pid
  Rake::Task["hydra:import_fixture"].reenable
  Rake::Task["hydra:import_fixture"].invoke  
end

# delete all the objects in the passed array of pids (from Fedora and Solr)
def delete_all(pids)
  pids.each { |pid|  
    delete(pid) 
  }
end

# delete an object (from Fedora and Solr)
def delete(pid)
  ENV["fixture"] = nil
  ENV["pid"] = pid
  Rake::Task["hydra:delete"].reenable
  Rake::Task["hydra:delete"].invoke  
end

# refresh (delete, then load) all the fixtures in the passed array of pids
#   pid is converted to file name by substituting : for _
def refresh_fixtures(fixture_pids)
  delete_all(fixture_pids)
  load_fixtures(fixture_pids)
end
