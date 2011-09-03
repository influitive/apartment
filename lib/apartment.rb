require 'apartment/railtie'

module Apartment
  
  class << self
    attr_accessor :use_postgres_schemas, :seed_after_create, :prepend_environment
    attr_writer :database_names, :excluded_models
    
    # configure apartment with available options
    def configure
      yield self if block_given?
      Database.init
    end
    
    # Be careful not to use `return` here so both Proc and lambda can be used without breaking
    def database_names
      if @database_names.respond_to?(:call)
        @database_names.call
      else
        @database_names
      end
    end
    
    # Default to none
    def excluded_models
      @excluded_models || []
    end
    
  end
  
  autoload :Database, 'apartment/database'
  autoload :Migrator, 'apartment/migrator'
  
  module Adapters
    autoload :AbstractAdapter, 'apartment/adapters/abstract_adapter'
    # Specific adapters will be loaded dynamically based on adapter in config
  end
  
  module Elevators
    autoload :Subdomain, 'apartment/elevators/subdomain'
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
  
  # Raised when database cannot find the specified schema
  class SchemaNotFound < ApartmentError; end
  
  # Raised when trying to create a schema that already exists
  class SchemaExists < ApartmentError; end
  
  # Raised when an ActiveRecord object does not have the required database field on it
  class DJSerializationError < ApartmentError; end
  
end

Apartment.configure do |config|
  config.excluded_models = []
  config.use_postgres_schemas = true
  config.database_names = []
  config.seed_after_create = false
  config.prepend_environment = true
end