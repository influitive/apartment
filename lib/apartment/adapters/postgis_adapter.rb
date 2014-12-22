# handle postgis adapter as if it were postgresql,
# only override the adapter_method used for initialization
require "apartment/adapters/postgresql_adapter"

module Apartment
  module Tenant

    def self.postgis_adapter(config)
      postgresql_adapter(config)
    end
  end
end
