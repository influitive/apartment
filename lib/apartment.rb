require 'apartment/railtie'

module Apartment

  autoload :ApartmentError, 'apartment/errors'
  autoload :Config, 'apartment/config'
  autoload :Database, 'apartment/database'
  
  module Adapters
    autoload :AbstractAdapter, 'apartment/adapters/abstract_adapter'
  end
end

