# frozen_string_literal: true

require 'apartment/railtie' if defined?(Rails)
require 'active_support/core_ext/object/blank'
require 'forwardable'
require 'active_record'
require 'apartment/tenant'

require_relative 'apartment/log_subscriber'

if ActiveRecord.version.release >= Gem::Version.new('6.0')
  require_relative 'apartment/active_record/connection_handling'
end

if ActiveRecord.version.release >= Gem::Version.new('6.1')
  require_relative 'apartment/active_record/schema_migration'
  require_relative 'apartment/active_record/internal_metadata'
end

# Apartment main definitions
module Apartment
  class << self
    extend Forwardable

    ACCESSOR_METHODS = %i[use_schemas use_sql seed_after_create prepend_environment default_tenant
                          append_environment with_multi_server_setup tenant_presence_check active_record_log].freeze

    WRITER_METHODS = %i[tenant_names database_schema_file excluded_models
                        persistent_schemas connection_class
                        db_migrate_tenants db_migrate_tenant_missing_strategy seed_data_file
                        parallel_migration_threads pg_excluded_names].freeze

    attr_accessor(*ACCESSOR_METHODS)
    attr_writer(*WRITER_METHODS)

    if ActiveRecord.version.release >= Gem::Version.new('6.1')
      def_delegators :connection_class, :connection, :connection_db_config, :establish_connection

      def connection_config
        connection_db_config.configuration_hash
      end
    else
      def_delegators :connection_class, :connection, :connection_config, :establish_connection
    end

    # configure apartment with available options
    def configure
      yield self if block_given?
    end

    def tenant_names
      extract_tenant_config.keys.map(&:to_s)
    end

    def tenants_with_config
      extract_tenant_config
    end

    def tld_length=(_)
      Apartment::Deprecation.warn('`config.tld_length` have no effect because it was removed in https://github.com/influitive/apartment/pull/309')
    end

    def db_config_for(tenant)
      (tenants_with_config[tenant] || connection_config)
    end

    # Whether or not db:migrate should also migrate tenants
    # defaults to true
    def db_migrate_tenants
      return @db_migrate_tenants if defined?(@db_migrate_tenants)

      @db_migrate_tenants = true
    end

    # How to handle tenant missing on db:migrate
    # defaults to :rescue_exception
    # available options: rescue_exception, raise_exception, create_tenant
    def db_migrate_tenant_missing_strategy
      valid = %i[rescue_exception raise_exception create_tenant]
      value = @db_migrate_tenant_missing_strategy || :rescue_exception

      return value if valid.include?(value)

      key_name  = 'config.db_migrate_tenant_missing_strategy'
      opt_names = valid.join(', ')

      raise ApartmentError, "Option #{value} not valid for `#{key_name}`. Use one of #{opt_names}"
    end

    # Default to empty array
    def excluded_models
      @excluded_models || []
    end

    def parallel_migration_threads
      @parallel_migration_threads || 0
    end

    def persistent_schemas
      @persistent_schemas || []
    end

    def connection_class
      @connection_class || ActiveRecord::Base
    end

    def database_schema_file
      return @database_schema_file if defined?(@database_schema_file)

      @database_schema_file = Rails.root.join('db/schema.rb')
    end

    def seed_data_file
      return @seed_data_file if defined?(@seed_data_file)

      @seed_data_file = Rails.root.join('db/seeds.rb')
    end

    def pg_excluded_names
      @pg_excluded_names || []
    end

    # Reset all the config for Apartment
    def reset
      (ACCESSOR_METHODS + WRITER_METHODS).each do |method|
        remove_instance_variable(:"@#{method}") if instance_variable_defined?(:"@#{method}")
      end
    end

    def extract_tenant_config
      return {} unless @tenant_names

      values = @tenant_names.respond_to?(:call) ? @tenant_names.call : @tenant_names
      unless values.is_a? Hash
        values = values.each_with_object({}) do |tenant, hash|
          hash[tenant] = connection_config
        end
      end
      values.with_indifferent_access
    rescue ActiveRecord::StatementInvalid
      {}
    end
  end

  # Exceptions
  ApartmentError = Class.new(StandardError)

  # Raised when apartment cannot find the adapter specified in <tt>config/database.yml</tt>
  AdapterNotFound = Class.new(ApartmentError)

  # Raised when apartment cannot find the file to be loaded
  FileNotFound = Class.new(ApartmentError)

  # Tenant specified is unknown
  TenantNotFound = Class.new(ApartmentError)

  # The Tenant attempting to be created already exists
  TenantExists = Class.new(ApartmentError)
end
