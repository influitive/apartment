require 'apartment/migrator'
require 'parallel'

apartment_namespace = namespace :apartment do

  desc "Create all multi-tenant databases"
  task :create => 'db:migrate' do
    each_db do |db|
      begin
        puts("Creating #{db} database")
        quietly { Apartment::Database.create(db) }
      rescue Apartment::DatabaseExists, Apartment::SchemaExists => e
        puts e.message
      end
    end
  end

  desc "Migrate all multi-tenant databases"
  task :migrate => 'db:migrate' do

    each_db do |db|
      begin
        puts("Migrating #{db} database")
        Apartment::Migrator.migrate db
      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  desc "Seed all multi-tenant databases"
  task :seed => 'db:seed' do

    each_db do |db|
      begin
        puts("Seeding #{db} database")
        Apartment::Database.process(db) do
          Apartment::Database.seed
        end
      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  desc "Rolls the schema back to the previous version (specify steps w/ STEP=n) across all multi-tenant dbs."
  task :rollback => 'db:rollback' do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    each_db do |db|
      begin
        puts("Rolling back #{db} database")
        Apartment::Migrator.rollback db, step
      rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
        puts e.message
      end
    end
  end

  namespace :migrate do

    desc 'Runs the "up" for a given migration VERSION across all multi-tenant dbs.'
    task :up => 'db:migrate:up' do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      each_db do |db|
        begin
          puts("Migrating #{db} database up")
          Apartment::Migrator.run :up, db, version
        rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
          puts e.message
        end
      end
    end

    desc 'Runs the "down" for a given migration VERSION across all multi-tenant dbs.'
    task :down => 'db:migrate:down' do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      each_db do |db|
        begin
          puts("Migrating #{db} database down")
          Apartment::Migrator.run :down, db, version
        rescue Apartment::DatabaseNotFound, Apartment::SchemaNotFound => e
          puts e.message
        end
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

  def each_db(&block)
    Parallel.each(database_names, :in_threads=>Apartment.parallel_migration_threads) do |db|
      ActiveRecord::Base.connection.reconnect!
      block.call(db)
    end
  end

  def database_names
    ENV['DB'] ? ENV['DB'].split(',').map { |s| s.strip } : Apartment.database_names
  end
end
