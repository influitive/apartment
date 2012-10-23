apartment_namespace = namespace :apartment do

  desc "Creates all multi-tenant databases"
  task :create => ['environment', 'db:load_config'] do

    Apartment.database_names.each do |db|
      puts("Creating #{db} database")
      Apartment::Migrator.create db
    end
  end

  desc "Drops all multi-tenant databases"
  task :drop => ['environment', 'db:load_config'] do

    Apartment.database_names.each do |db|
      puts("Dropping #{db} database")
      Apartment::Migrator.drop db
    end
  end

  desc "Migrate all multi-tenant databases"
  task :migrate => 'db:migrate' do

    Apartment.database_names.each do |db|
      puts("Migrating #{db} database")
      Apartment::Migrator.migrate db
    end
  end

  desc "Seed all multi-tenant databases"
  task :seed => 'db:seed' do

    Apartment.database_names.each do |db|
      puts("Seeding #{db} database")
      Apartment::Database.process(db) do
        Apartment::Database.seed
      end
    end
  end

  desc "Rolls the schema back to the previous version (specify steps w/ STEP=n) across all multi-tenant dbs."
  task :rollback => 'db:rollback' do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    Apartment.database_names.each do |db|
      puts("Rolling back #{db} database")
      Apartment::Migrator.rollback db, step
    end
  end

  desc "Resets all multi-tenant databases"
  task :reset => ['apartment:drop', 'apartment:create', 'apartment:migrate']

  namespace :migrate do

    desc 'Runs the "up" for a given migration VERSION across all multi-tenant dbs.'
    task :up => 'db:migrate:up' do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      Apartment.database_names.each do |db|
        puts("Migrating #{db} database up")
        Apartment::Migrator.run :up, db, version
      end
    end

    desc 'Runs the "down" for a given migration VERSION across all multi-tenant dbs.'
    task :down => 'db:migrate:down' do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      Apartment.database_names.each do |db|
        puts("Migrating #{db} database down")
        Apartment::Migrator.run :down, db, version
      end
    end

    desc  'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo => 'db:migrate:redo' do
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
