apartment_namespace = namespace :apartment do
  
	desc "Migrate all multi-tenant databases"
	task :migrate => :environment do
		ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path)

		Apartment.database_names.each do |db| 
		  puts("Migrating #{db} database")
		  Apartment::Migrator.migrate db
	  end
	end
	
	desc "Seed all multi-tenant databases"
	task :seed => :environment do
	  Apartment::Database.seed
	  
	  Apartment.database_names.each do |db| 
      puts("Seeding #{db} database")
      Apartment::Database.process(db) do
        Apartment::Database.seed
      end
    end
  end
	
	desc "Rolls the schema back to the previous version (specify steps w/ STEP=n) across all multi-tenant dbs."
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_path, step)
    
    Apartment.database_names.each do |db| 
      puts("Rolling back #{db} database")
      Apartment::Migrator.rollback db, step
    end
  end
	
	namespace :migrate do
	  
	  desc 'Runs the "up" for a given migration VERSION across all multi-tenant dbs.'
	  task :up => :environment do
	    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_path, version)
      
      Apartment.database_names.each do |db| 
        puts("Migrating #{db} database up")
        Apartment::Migrator.run :up, db, version
      end
    end
	  
	  desc 'Runs the "down" for a given migration VERSION across all multi-tenant dbs.'
	  task :down => :environment do
	    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version
      ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_path, version)
      
      Apartment.database_names.each do |db| 
        puts("Migrating #{db} database down")
        Apartment::Migrator.run :down, db, version
      end
    end
    
    desc  'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo => :environment do
      if ENV['VERSION']
        apartment_namespace['migrate:down'].invoke
        apartment_namespace['migrate:up'].invoke
      else
        apartment_namespace['rollback'].invoke
        apartment_namespace['migrate'].invoke
      end
    end
    
  end
  
end