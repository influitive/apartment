# frozen_string_literal: true

require 'rails'
require 'apartment/tenant'
require 'apartment/reloader'

module Apartment
  class Railtie < Rails::Railtie
    #
    #   Set up our default config options
    #   Do this before the app initializers run so we don't override custom settings
    #
    config.before_initialize do
      Apartment.configure do |config|
        config.excluded_models = []
        config.use_schemas = true
        config.tenant_names = []
        config.seed_after_create = false
        config.prepend_environment = false
        config.append_environment = false
        config.tenant_presence_check = true
        config.active_record_log = false
      end

      ActiveRecord::Migrator.migrations_paths = Rails.application.paths['db/migrate'].to_a
    end

    # Make sure Apartment is reconfigured when the code is reloaded
    config.to_prepare do
      Apartment::Tenant.reinitialize
    end

    #
    # Ensure that Apartment::Tenant.init is called when
    # a new connection is requested.
    #
    module ApartmentInitializer
      def connection
        super.tap do
          Apartment::Tenant.init_once
        end
      end

      def arel_table
        Apartment::Tenant.init_once
        super
      end
    end
    ActiveRecord::Base.singleton_class.prepend ApartmentInitializer

    #
    #   Ensure rake tasks are loaded
    #
    rake_tasks do
      load 'tasks/apartment.rake'
      require 'apartment/tasks/enhancements' if Apartment.db_migrate_tenants
    end

    #
    #   The following initializers are a workaround to the fact that I can't
    #   properly hook into the rails reloader
    #   Note this is technically valid for any environment where cache_classes
    #   is false, for us, it's just development
    #
    if Rails.env.development?

      # Apartment::Reloader is middleware to initialize things properly on each request to dev
      initializer 'apartment.init' do |app|
        app.config.middleware.use Apartment::Reloader
      end

      # Overrides reload! to also call Apartment::Tenant.init as well so that the
      # reloaded classes have the proper table_names
      console do
        require 'apartment/console'
      end
    end
  end
end
