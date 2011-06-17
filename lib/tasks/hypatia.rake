require 'spec/rake/spectask'
require "cucumber/rake/task"

namespace :hypatia do

  desc "Execute Continuous Integration build (docs, tests with coverage)"
  task :ci do
    
    Rake::Task["hypatia:reset"].invoke
    
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
      :startup_wait => 20
      }
    
    # does this make jetty run in TEST environment???
    error = Jettywrapper.wrap(jetty_params) do
      Rake::Task["hypatia:spec"].invoke
      system("rake hypatia:fixtures:refresh environment=test")
      Rake::Task["hypatia:cucumber:run"].invoke
    end
    raise "test failures: #{error}" if error
  end

  desc "return hypatia project code to pristine latest from git"
  task :reset do
      system("git reset --hard HEAD && git clean -dfx")
      sleep 15
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

    desc "Run cucumber features for hypatia. Must have jetty already running and fixtures loaded."
    task :run do
      Cucumber::Rake::Task.new(:run) do |t|
        t.rcov = true
        t.cucumber_opts = %w{--color --tags ~@pending --tags ~@overwritten features}
      end
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
        sleep 15
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
        sleep 15
      end

      desc "return development jetty to its pristine state, then load our Solr and Fedora config files"
      task :reset_then_config do
        Rake::Task["hypatia:jetty:dev:reset"].invoke
        Rake::Task["hydra:jetty:config"].invoke
      end
    end # namespace hypatia:jetty:dev
        
  end # namespace hypatia:jetty

#============= FIXTURE TASKS ================
  namespace :fixtures do
    
    desc "Load all Hypatia fixtures"
    task :load => ['xanadu:load'] 

    desc "Remove all Hypatia fixtures"
    task :delete => ['xanadu:delete']

    desc "Remove then load all Hypatia fixtures"
    task :refresh => ['xanadu:refresh'] 

    namespace :xanadu do
      XANADU_FIXTURE_PIDS = [
        "hypatia:fixture_xanadu_collection",
        "hypatia:fixture_xanadu_drive1",
        "hypatia:fixture_xanadu_drive2",
        "hypatia:fixture_xanadu_drive3",
        "hypatia:fixture_xanadu_drive1.dd"
      ]

      desc "Load Hypatia Xanadu fixtures"
      task :load do
        # pids are converted to file names by substituting : for _
        load_fixtures(XANADU_FIXTURE_PIDS)
      end

      desc "Remove Hypatia Xanadu fixtures"
      task :delete do
        delete_fixtures(XANADU_FIXTURE_PIDS)
      end

      desc "Remove then load Hypatia Xanadu fixtures"
      task :refresh do
        refresh_fixtures(XANADU_FIXTURE_PIDS)
      end
    end # hypatia:fixtures:xanadu namespace

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
    if File.exists?(doc_destination) 
      FileUtils.remove_dir(doc_destination)
    end
    FileUtils.mkdir_p(doc_destination)

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

# delete all the fixtures in the passed array of pids
def delete_fixtures(fixture_pids)
  fixture_pids.each { |pid|  
    delete_fixture(pid) 
  }
end

# delete a fixture object
def delete_fixture(fixture_pid)
  ENV["fixture"] = nil
  ENV["pid"] = fixture_pid
  Rake::Task["hydra:delete"].reenable
  Rake::Task["hydra:delete"].invoke  
end

# refresh (delete, then load) all the fixtures in the passed array of pids
#   pid is converted to file name by substituting : for _
def refresh_fixtures(fixture_pids)
  delete_fixtures(fixture_pids)
  load_fixtures(fixture_pids)
end
