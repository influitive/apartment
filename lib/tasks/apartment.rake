apartment_namespace = namespace :apartment do

  desc "Migrate all or one of the multi-tenant databases"
  task :migrate, [:db] => 'db:migrate' do |t, args|
    if args[:db].present?
      puts "Migrating #{args[:db]} database"
      Apartment::Migrator.migrate args[:db]
    else
      Apartment.database_names.each do |db|
        puts("Migrating #{db} database")
        Apartment::Migrator.migrate db
      end
    end
  end

  desc "Seed all or one of the multi-tenant databases"
  task :seed, [:db] => 'db:seed' do |t, args|
    if args[:db].present?
      puts "Seeding #{args[:db]} database"
      Apartment::Database.process(args[:db]) do
        Apartment::Database.seed
      end
    else
      Apartment.database_names.each do |db|
        puts("Seeding #{db} database")
        Apartment::Database.process(db) do
          Apartment::Database.seed
        end
      end
    end
  end

  desc "Rolls the schema back to the previous version (specify steps w/ STEP=n) across all or one of the multi-tenant dbs."
  task :rollback, [:db] => 'db:rollback' do |t, args|
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    if args[:db].present?
      puts "Rolling back #{args[:db]} database"
      Apartment::Migrator.rollback args[:db], step
    else
      Apartment.database_names.each do |db|
        puts("Rolling back #{db} database")
        Apartment::Migrator.rollback db, step
      end
    end
  end

  namespace :migrate do

    desc 'Runs the "up" for a given migration VERSION across all or one of the multi-tenant dbs.'
    task :up, [:db] => 'db:migrate:up' do |t, args|
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      if args[:db].present?
        puts "Migrating #{args[:db]} database up"
        Apartment::Migrator.run :up, args[:db], version
      else
        Apartment.database_names.each do |db|
          puts("Migrating #{db} database up")
          Apartment::Migrator.run :up, db, version
        end
      end
    end

    desc 'Runs the "down" for a given migration VERSION across all or one of the multi-tenant dbs.'
    task :down, [:db] => 'db:migrate:down' do |t, args|
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      if args[:db].present?
        puts "Migrating #{args[:db]} database down"
        Apartment::Migrator.run :down, args[:db], version
      else
        Apartment.database_names.each do |db|
          puts("Migrating #{db} database down")
          Apartment::Migrator.run :down, db, version
        end
      end
    end

    desc 'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo, [:db] => 'db:migrate:redo' do |t, args|
      if args[:db].present?
        if ENV['VERSION']
          apartment_namespace['migrate:down'].invoke(args[:db])
          apartment_namespace['migrate:up'].invoke(args[:db])
        else
          apartment_namespace['rollback'].invoke(args[:db])
          apartment_namespace['migrate'].invoke(args[:db])
        end
      else
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
end