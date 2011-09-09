module Apartment
  module Test
    
    extend self
    
    def reset
      Apartment::Database.instance_variable_set :@initialized, nil
      Apartment.excluded_models = nil
      Apartment.use_postgres_schemas = nil
    end
    
    def drop_schema(schema)
      ActiveRecord::Base.silence{ ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE") }
    end
    
    def create_schema(schema)
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema}")
    end
    
    def load_schema
      load "#{Rails.root}/db/schema.rb"
    end
    
    def migrate
      ActiveRecord::Migrator.migrate(Rails.root + ActiveRecord::Migrator.migrations_path)
    end
    
    def rollback
      ActiveRecord::Migrator.rollback(Rails.root + ActiveRecord::Migrator.migrations_path)
    end
    
    private
    
    def sanitize(database)
      database.gsub(/[\W]/,'')
    end
    
  end
end