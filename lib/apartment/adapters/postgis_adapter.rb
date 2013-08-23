# handle postgis adapter as if it were postgresql,
# only override the adapter_method used for initialization
require "apartment/adapters/postgresql_adapter"

module Apartment
  module Database

    def self.postgis_adapter(config)
      Apartment.use_schemas ?
        Adapters::PostgresqlSchemaAdapter.new(config) :
        Adapters::PostgresqlAdapter.new(config)
    end
  end
end
