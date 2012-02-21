module Apartment
  module Test
    
    extend self
    
    def reset
      Apartment.excluded_models = nil
      Apartment.use_postgres_schemas = nil
    end
    
    def drop_schema(schema)
      ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE") rescue true
    end
    
    def create_schema(schema)
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema}")
    end
    
    def load_schema
      silence_stream(STDOUT){ load("#{Rails.root}/db/schema.rb") }
    end
    
    def migrate
      ActiveRecord::Migrator.migrate(Rails.root + ActiveRecord::Migrator.migrations_path)
    end
    
    def rollback
      ActiveRecord::Migrator.rollback(Rails.root + ActiveRecord::Migrator.migrations_path)
    end
    
  end
end