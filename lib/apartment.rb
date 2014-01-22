require 'apartment/railtie' if defined?(Rails)
require 'active_support/core_ext/object/blank'
require 'forwardable'
require 'active_record'
require 'apartment/database'

module Apartment

  class << self

    extend Forwardable

    ACCESSOR_METHODS  = [:use_schemas, :seed_after_create, :prepend_environment, :append_environment]
    WRITER_METHODS    = [:database_names, :database_schema_file, :excluded_models, :default_schema, :persistent_schemas, :connection_class, :schema_format]

    attr_accessor(*ACCESSOR_METHODS)
    attr_writer(*WRITER_METHODS)

    def_delegators :connection_class, :connection, :establish_connection

    # configure apartment with available options
    def configure
      yield self if block_given?
    end

    # Be careful not to use `return` here so both Proc and lambda can be used without breaking
    def database_names
      @database_names.respond_to?(:call) ? @database_names.call : @database_names
    end

    # Default to empty array
    def excluded_models
      @excluded_models || []
    end

    def default_schema
      @default_schema || "public"
    end

    def persistent_schemas
      @persistent_schemas || []
    end

    def connection_class
      @connection_class || ActiveRecord::Base
    end

    # Schema format :ruby or :sql
    # as per http://guides.rubyonrails.org/configuring.html#configuring-rails-components
    def schema_format
      @schema_format || :ruby
    end

    def database_schema_file
      return @database_schema_file if defined?(@database_schema_file)

      if defined?(Rails)
        @database_schema_file = if schema_format == :sql
          Rails.root.join('db', 'structure.sql')
        else
          Rails.root.join('db', 'schema.rb')
        end
      end
    end

    # Reset all the config for Apartment
    def reset
      (ACCESSOR_METHODS + WRITER_METHODS).each{|method| remove_instance_variable(:"@#{method}") if instance_variable_defined?(:"@#{method}") }
    end

    def use_postgres_schemas
      warn "[Deprecation Warning] `use_postgresql_schemas` is now deprecated, please use `use_schemas`"
      use_schemas
    end

    def use_postgres_schemas=(to_use_or_not_to_use)
      warn "[Deprecation Warning] `use_postgresql_schemas=` is now deprecated, please use `use_schemas=`"
      self.use_schemas = to_use_or_not_to_use
    end
  end

  # Exceptions
  ApartmentError = Class.new(StandardError)

  # Raised when apartment cannot find the adapter specified in <tt>config/database.yml</tt>
  AdapterNotFound = Class.new(ApartmentError)

  # Tenant specified is unknown
  TenantNotFound = Class.new(ApartmentError)

  # Raised when database cannot find the specified database
  DatabaseNotFound = Class.new(TenantNotFound)

  # Raised when database cannot find the specified schema
  SchemaNotFound = Class.new(TenantNotFound)

  # The Tenant attempting to be created already exists
  TenantExists = Class.new(ApartmentError)

  # Raised when trying to create a database that already exists
  DatabaseExists = Class.new(TenantExists)

  # Raised when trying to create a schema that already exists
  SchemaExists = Class.new(TenantExists)
end
