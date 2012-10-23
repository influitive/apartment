require 'apartment/railtie' if defined?(Rails)

module Apartment

  class << self
    ACCESSOR_METHODS  = [:use_postgres_schemas, :seed_after_create, :prepend_environment, :append_environment]
    WRITER_METHODS    = [:database_names, :excluded_models, :default_schema, :persistent_schemas]

    attr_accessor(*ACCESSOR_METHODS)
    attr_writer(*WRITER_METHODS)

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

    # Reset all the config for Apartment
    def reset
      (ACCESSOR_METHODS + WRITER_METHODS).each{|method| instance_variable_set(:"@#{method}", nil) }
    end

  end

  autoload :Database, 'apartment/database'
  autoload :Migrator, 'apartment/migrator'
  autoload :Reloader, 'apartment/reloader'

  module Adapters
    autoload :AbstractAdapter, 'apartment/adapters/abstract_adapter'
    # Specific adapters will be loaded dynamically based on adapter in config
  end

  module Elevators
    autoload :Generic,    'apartment/elevators/generic'
    autoload :Subdomain,  'apartment/elevators/subdomain'
    autoload :Domain,     'apartment/elevators/domain'
  end

  module Delayed

    autoload :Requirements, 'apartment/delayed_job/requirements'

    module Job
      autoload :Hooks, 'apartment/delayed_job/hooks'
    end
  end

  # Exceptions
  class ApartmentError < StandardError; end

  # Raised when apartment cannot find the adapter specified in <tt>config/database.yml</tt>
  class AdapterNotFound < ApartmentError; end

  # Raised when database cannot find the specified database
  class DatabaseNotFound < ApartmentError; end

  # Raised when trying to create a database that already exists
  class DatabaseExists < ApartmentError; end

  # Raised when database cannot find the specified schema
  class SchemaNotFound < ApartmentError; end

  # Raised when trying to create a schema that already exists
  class SchemaExists < ApartmentError; end

  # Raised when an ActiveRecord object does not have the required database field on it
  class DJSerializationError < ApartmentError; end

  def self.method_missing(meth, *args, &block)
    if meth.to_s =~ /^use_(.+)$/
      Apartment::Database.switch($1)
    else
      super
    end
  end

end
