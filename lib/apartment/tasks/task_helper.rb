# frozen_string_literal: true

module Apartment
  module TaskHelper
    def self.each_tenant(&block)
      Parallel.each(tenants_without_default, in_threads: Apartment.parallel_migration_threads) do |tenant|
        block.call(tenant)
      end
    end

    def self.tenants_without_default
      tenants - [Apartment.default_tenant]
    end

    def self.tenants
      ENV['DB'] ? ENV['DB'].split(',').map(&:strip) : Apartment.tenant_names || []
    end

    def self.warn_if_tenants_empty
      return unless tenants.empty? && ENV['IGNORE_EMPTY_TENANTS'] != 'true'

      puts <<-WARNING
        [WARNING] - The list of tenants to migrate appears to be empty. This could mean a few things:

          1. You may not have created any, in which case you can ignore this message
          2. You've run `apartment:migrate` directly without loading the Rails environment
            * `apartment:migrate` is now deprecated. Tenants will automatically be migrated with `db:migrate`

        Note that your tenants currently haven't been migrated. You'll need to run `db:migrate` to rectify this.
      WARNING
    end

    def self.create_tenant(tenant_name)
      begin
        Apartment::Tenant.create(tenant_name)
      rescue Apartment::TenantExists => e
        puts 'Tried to create already existing tenant'
      end
    end
  end
end
