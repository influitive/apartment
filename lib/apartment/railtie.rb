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

    #   Hook into ActionDispatch::Reloader to ensure Apartment is properly initialized
    #   Note that this doesn't entirely work as expected in Development,
    #   because this is called before classes are reloaded
    #   See the middleware/console declarations below to help with this. Hope to fix that soon.
    #
    config.to_prepare do
      next if ARGV.any? { |arg| arg =~ /\Aassets:(?:precompile|clean)\z/ }
      next if ARGV.any? { |arg| arg == 'webpacker:compile' }
      next if ENV['APARTMENT_DISABLE_INIT']

      begin
        Apartment.connection_class.connection_pool.with_connection do
          Apartment::Tenant.init
        end
      rescue ::ActiveRecord::NoDatabaseError
        # Since `db:create` and other tasks invoke this block from Rails 5.2.0,
        # we need to swallow the error to execute `db:create` properly.
      end
    end

    config.after_initialize do
      # NOTE: Load the custom log subscriber if enabled
      if Apartment.active_record_log
        ActiveSupport::Notifications.unsubscribe 'sql.active_record'
        Apartment::LogSubscriber.attach_to :active_record
      end
    end

    #
    #   Ensure rake tasks are loaded
    #
    rake_tasks do
      load 'tasks/apartment.rake'
      require 'apartment/tasks/enhancements' if Apartment.db_migrate_tenants
    end

    #
    #   The following initializers are a workaround to the fact that I can't properly hook into the rails reloader
    #   Note this is technically valid for any environment where cache_classes is false, for us, it's just development
    #
    if Rails.env.development?

      # Apartment::Reloader is middleware to initialize things properly on each request to dev
      initializer 'apartment.init' do |app|
        app.config.middleware.use Apartment::Reloader
      end

      # Overrides reload! to also call Apartment::Tenant.init as well
      # so that the reloaded classes have the proper table_names
      # rubocop:disable Lint/Debugger
      console do
        require 'apartment/console'
      end
      # rubocop:enable Lint/Debugger
    end
  end
end
