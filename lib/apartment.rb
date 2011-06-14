require 'apartment/railtie'

module Apartment
  
  class << self
    attr_accessor :excluded_models, :use_postgres_schemas
    attr_writer :database_names
    
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
    
  end
  
  autoload :Database, 'apartment/database'
  autoload :Migrator, 'apartment/migrator'
  
  # Exceptions
  autoload :ApartmentError, 'apartment/errors'
  autoload :AdapterNotFound, 'apartment/errors'
  autoload :SchemaNotFound, 'apartment/errors'
  
  module Adapters
    autoload :AbstractAdapter, 'apartment/adapters/abstract_adapter'
    # Specific adapters will be loaded dynamically based on adapter in config
  end
  
end

Apartment.configure do |config|
  config.excluded_models = []
  config.use_postgres_schemas = true
  config.database_names = lambda{ [] }
end