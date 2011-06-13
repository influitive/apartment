require 'apartment/railtie'
require 'apartment/config'
require 'apartment/database'

module Apartment

  autoload :ApartmentError, 'apartment/errors'
  autoload :Database, 'aparment/database'
  
  module Adapters
    autoload AbstractAdapter, 'apartment/adapters/abstract_adapter'
  end
end

