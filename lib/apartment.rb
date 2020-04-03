# frozen_string_literal: true

require 'apartment/railtie' if defined?(Rails)
require 'active_support/core_ext/object/blank'
require 'forwardable'
require 'active_record'
require 'apartment/tenant'

if ActiveRecord.version.release >= Gem::Version.new('6.1')
  require_relative 'apartment/active_record/schema_migration'
  require_relative 'apartment/active_record/internal_metadata'
end

module Apartment
  class << self
    extend Forwardable

    ACCESSOR_METHODS = %i[use_schemas use_sql seed_after_create prepend_environment
                          append_environment with_multi_server_setup].freeze

    WRITER_METHODS = %i[tenant_names database_schema_file excluded_models
                        default_schema persistent_schemas connection_class
                        tld_length db_migrate_tenants seed_data_file
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

    def db_config_for(tenant)
      (tenants_with_config[tenant] || connection_config)
    end

    # Whether or not db:migrate should also migrate tenants
    # defaults to true
    def db_migrate_tenants
      return @db_migrate_tenants if defined?(@db_migrate_tenants)

      @db_migrate_tenants = true
    end

    # Default to empty array
    def excluded_models
      @excluded_models || []
    end

    def default_schema
      @default_schema || 'public' # TODO: 'public' is postgres specific
    end

    def parallel_migration_threads
      @parallel_migration_threads || 0
    end
    alias default_tenant default_schema
    alias default_tenant= default_schema=

    def persistent_schemas
      @persistent_schemas || []
    end

    def connection_class
      @connection_class || ActiveRecord::Base
    end

    def database_schema_file
      return @database_schema_file if defined?(@database_schema_file)

      @database_schema_file = Rails.root.join('db', 'schema.rb')
    end

    def seed_data_file
      return @seed_data_file if defined?(@seed_data_file)

      @seed_data_file = Rails.root.join('db', 'seeds.rb')
    end

    def pg_excluded_names
      @pg_excluded_names || []
    end

    # Reset all the config for Apartment
    def reset
      (ACCESSOR_METHODS + WRITER_METHODS).each { |method| remove_instance_variable(:"@#{method}") if instance_variable_defined?(:"@#{method}") }
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

if ActiveRecord.version.release >= Gem::Version.new('6.0')
  module ActiveRecord
    module ConnectionHandling
      def connected_to_with_tenant(database: nil, role: nil, prevent_writes: false, &blk)
        connected_to_without_tenant(database: database, role: role, prevent_writes: prevent_writes) do
          Apartment::Tenant.switch!(Apartment::Tenant.current)
          yield(blk)
        end
      end

      alias connected_to_without_tenant connected_to
      alias connected_to connected_to_with_tenant
    end
  end
end
