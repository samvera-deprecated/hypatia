require 'spec/rake/spectask'

namespace :hypatia do

  namespace :fixtures do
    
    # "load array of fixtures"
    task :load, [:fixture_pids] do |t, pids|
      puts pids.inspect
      pids.each do |pid|
        load_fixture(pid)
      end
    end
    
    # "delete array of fixtures"
    task :delete, [:fixture_pids] do |t, pids|
      pids.each do |pid|
        load_fixture(pid)
      end
    end

    namespace :xanadu do

      XANADU_FIXTURE_PIDS = [
        "hypatia:fixture_xanadu_collection",
        "hypatia:fixture_xanadu_drive1",
        "hypatia:fixture_xanadu_drive2",
        "hypatia:fixture_xanadu_drive3",
        "hypatia:fixture_xanadu_drive1.dd"
      ]

      desc "Load default Hydra fixtures"
      task :load do
        # pids are converted to file names by substituting : for _
        load_fixtures(XANADU_FIXTURE_PIDS)
      end

      desc "Remove default Hydra fixtures"
      task :delete do
        delete_fixtures(XANADU_FIXTURE_PIDS)
      end

      desc "Refresh default Hydra fixtures"
      task :refresh do
        refresh_fixtures(XANADU_FIXTURE_PIDS)
      end

    end # hypatia:fixtures:xanadu namespace

  end # hypatia:fixtures namespace

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
