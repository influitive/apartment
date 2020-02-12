require 'apartment/adapters/mysql2_adapter'

module Apartment
  module Tenant
    
    def self.mysql2_json_adapter(config)
      Apartment.use_schemas ?
        Adapters::Mysql2SchemaAdapter.new(config) :
        Adapters::Mysql2Adapter.new(config)
    end
  end

  module Adapters
    class Mysql2JsonAdapter < Mysql2Adapter
    end
  end
end
