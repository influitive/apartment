module Apartment
  module Test
    def self.reset
      Apartment::Database.instance_variable_set :@initialized, nil
      Apartment.excluded_models = nil
      Apartment.use_postgres_schemas = nil
    end
  end
end