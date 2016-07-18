require 'apartment/railtie' if defined?(Rails)
require 'active_support/core_ext/object/blank'
require 'forwardable'
require 'active_record'
require 'apartment/tenant'
require 'apartment/deprecation'

module Apartment

  class << self

    extend Forwardable

    ACCESSOR_METHODS  = [:use_schemas, :use_sql, :seed_after_create, :prepend_environment, :append_environment]
    WRITER_METHODS    = [:tenant_names, :database_schema_file, :excluded_models, :default_tenant, :persistent_schemas, :connection_class, :tld_length, :db_migrate_tenants, :seed_data_file]

    attr_accessor(*ACCESSOR_METHODS)
    attr_writer(*WRITER_METHODS)

    def_delegators :connection_class, :connection, :connection_config, :establish_connection
    def_delegators :connection_handler, :switch_to_host

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
      (tenants_with_config[tenant] || connection_config).with_indifferent_access
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

    def default_tenant
      @default_tenant
    end

    def persistent_schemas
      @persistent_schemas || []
    end

    def connection_class
      @connection_class || ActiveRecord::Base
    end

    def connection_handler
      connection_class.connection_handler
    end

    def database_schema_file
      return @database_schema_file if defined?(@database_schema_file)

      @database_schema_file = Rails.root.join('db', 'schema.rb')
    end

    def seed_data_file
      return @seed_data_file if defined?(@seed_data_file)

      @seed_data_file = "#{Rails.root}/db/seeds.rb"
    end

    def tld_length
      @tld_length || 1
    end

    # Reset all the config for Apartment
    def reset
      (ACCESSOR_METHODS + WRITER_METHODS).each{|method| remove_instance_variable(:"@#{method}") if instance_variable_defined?(:"@#{method}") }
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

  # Tenant specified is unknown
  TenantNotFound = Class.new(ApartmentError)

  # The Tenant attempting to be created already exists
  TenantExists = Class.new(ApartmentError)
end
