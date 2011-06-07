namespace :apartment do
  
	desc "Migrate all multi-tenant databases"
	task :migrate => :environment do
		
		puts "Apartment :: [Migrating to default environment]"
		ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path)
    
		companies do |company|
		  puts "Apartment :: [Migrating to #{company.database}]"
			Apartment::Database.migrate company.database
		end
		
	end
	
	desc "Rolls the schema back to the previous version (specify steps w/ STEP=n) across all multi-tenant dbs."
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    companies do |company|
      Apartment::Database.rollback company.database, step
    end
  end
	
	namespace :migrate do
	  
	  desc 'Runs the "up" for a given migration VERSION across all multi-tenant dbs.'
	  task :up => :environment do
	    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      
      companies do |company|
        Apartment::Database.migrate_up company.database, version
      end
    end
	  
	  desc 'Runs the "down" for a given migration VERSION across all multi-tenant dbs.'
	  task :down => :environment do
	    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      
      companies do |company|
        Apartment::Database.migrate_down company.database, version
      end
    end
    
  end
  
  # Migrate public database as well as all multi-tenanted dbs
  def companies
    Admin::Company.where("database is not null").select("distinct database").each do |company|
      yield company if block_given?
		end
  end
end