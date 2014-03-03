require 'apartment/migrator'

apartment_namespace = namespace :apartment do

  task :init => ['environment', 'db:load_config']

  desc "Create all tenants"
  task create: :init do
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
  task migrate: :init do
    err_if_tenants_empty

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
  task seed: :init do
    err_if_tenants_empty

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
  task rollback: :init do
    err_if_tenants_empty

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

  namespace :tenant do
    desc "Migrate a single tenant: required paramter TENANT=name"
    task :migrate,[:tenant] => :init do |t, args|
      tenant = args.tenant || ENV['TENANT']

      err_if_tenants_empty
      raise 'TENANT is required' unless tenant
      raise "TENANT #{tenant} is unknown" if !tenants.include?(tenant)

      begin
        puts("Migrating #{tenant} tenant")
        Apartment::Migrator.migrate tenant 
      rescue Apartment::TenantNotFound => e
        puts e.message
      end
    end

    desc "Rolls the migration back to the previous version (specify steps w/ STEP=n) for one TENANT."
    task :rollback,[:tenant, :step] => :init do |t, args|
      tenant = args.tenant || ENV['TENANT']
      step = args.step || ENV['STEP'] ? ENV['STEP'].to_i : 1

      err_if_tenants_empty
      raise 'TENANT is required' unless tenant
      raise "TENANT #{tenant} is unknown" if !tenants.include?(tenant)

      begin
        puts("Rolling back #{tenant} tenant")
        Apartment::Migrator.rollback tenant, step
      rescue Apartment::TenantNotFound => e
        puts e.message
      end
    end

    desc 'Create a db/schema.rb file that can be portably used against any DB supported by AR'
    task :dump, [:tenant] => ['environment', 'db:load_config'] do |t, args|

      tenant = args.tenant || ENV['TENANT']

      err_if_tenants_empty
      raise 'TENANT is required' unless tenant
      raise "TENANT #{tenant} is unknown" if !tenants.include?(tenant)

      Apartment::Database.dump(tenant)

      # apartment_namespace['dump'].reenable
    end

    # desc 'Load a schema.rb file into the database'
    # task :load,[:tenant] => ['environment', 'db:load_config'] do |t, args|
    #   tenant = args.tenant || ENV['TENANT']

    #   err_if_tenants_empty
    #   raise 'TENANT is required' unless tenant
    #   raise "TENANT #{tenant} is unknown" if !tenants.include?(tenant)

    #   puts "apartment:tenant:load(#{tenant})"

    #   Apartment::Database.load(tenant)
    # end

  end


  namespace :migrate do

    desc 'Runs the "up" for a given migration VERSION across all tenants.'
    task up: :init do
      err_if_tenants_empty

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
    task down: :init do
      err_if_tenants_empty

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
    task redo: :init do
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
    ENV['DB'] ? ENV['DB'].split(',').map { |s| s.strip } : Apartment.tenant_names || []
  end

  def err_if_tenants_empty
    raise "tenants is empty" if tenants.empty?
  end
end
