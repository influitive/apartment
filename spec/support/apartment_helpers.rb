module Apartment
  module Test
    def self.reset
      Apartment::Database.instance_variable_set :@initialized, nil
      Apartment.excluded_models = nil
      Apartment.use_postgres_schemas = nil
    end
    
    def self.drop_schema(schema)
      ActiveRecord::Base.silence{ ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE") }
    end
    
    def self.create_schema(schema)
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema}")
    end
    
    def self.load_schema
      load "#{Rails.root}/db/schema.rb"
    end
    
    def self.in_database(db)
      Apartment::Database.switch db
      yield if block_given?
      Apartment::Database.reset
    end
    
  end
end