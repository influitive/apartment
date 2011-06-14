require 'apartment/railtie'

module Apartment

  autoload :Config, 'apartment/config'
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

