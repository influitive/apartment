module Apartment
  module Test
    def self.reset
      Apartment::Database.instance_variable_set :@initialized, nil
      Apartment.excluded_models = nil
      Apartment.use_postgres_schemas = nil
    end
    
    def self.drop_schema(schema)
      ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE")
    end
  end
end