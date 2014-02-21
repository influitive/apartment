require 'apartment/migrator'

apartment_namespace = namespace :apartment do

  desc "Create all tenants"
  task create: 'db:migrate' do
    tenants.each do |tenant|
      begin
        puts("Creating #{tenant} tenant")
        quietly { Apartment::Database.create(tenant) }
      rescue Apartment::TenantExists => e
        puts e.message
      end
    end
  end

  desc "Migrate all tenants"
  task :migrate do
    tenants.each do |tenant|
      begin
        puts("Migrating #{tenant} tenant")
        Apartment::Migrator.migrate tenant
      rescue Apartment::TenantNotFound => e
        puts e.message
      end
    end
  end

  desc "Seed all tenants"
  task :seed do
    tenants.each do |tenant|
      begin
        puts("Seeding #{tenant} tenant")
        Apartment::Database.process(tenant) do
          Apartment::Database.seed
        end
      rescue Apartment::TenantNotFound => e
        puts e.message
      end
    end
  end

  desc "Rolls the migration back to the previous version (specify steps w/ STEP=n) across all tenants."
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    tenants.each do |tenant|
      begin
        puts("Rolling back #{tenant} tenant")
        Apartment::Migrator.rollback tenant, step
      rescue Apartment::TenantNotFound => e
        puts e.message
      end
    end
  end

  namespace :migrate do
    desc 'Runs the "up" for a given migration VERSION across all tenants.'
    task :up do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      tenants.each do |tenant|
        begin
          puts("Migrating #{tenant} tenant up")
          Apartment::Migrator.run :up, tenant, version
        rescue Apartment::TenantNotFound => e
          puts e.message
        end
      end
    end

    desc 'Runs the "down" for a given migration VERSION across all tenants.'
    task :down do
      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      tenants.each do |tenant|
        begin
          puts("Migrating #{tenant} tenant down")
          Apartment::Migrator.run :down, tenant, version
        rescue Apartment::TenantNotFound => e
          puts e.message
        end
      end
    end

    desc  'Rolls back the tenant one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo do
      if ENV['VERSION']
        apartment_namespace['migrate:down'].invoke
        apartment_namespace['migrate:up'].invoke
      else
        apartment_namespace['rollback'].invoke
        apartment_namespace['migrate'].invoke
      end
    end
  end

  def tenants
    ENV['DB'] ? ENV['DB'].split(',').map { |s| s.strip } : Apartment.tenant_names
  end
end
