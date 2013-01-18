module Apartment
  module Test

    extend self

    def reset
      Apartment.excluded_models = nil
      Apartment.use_schemas = nil
      Apartment.seed_after_create = nil
      Apartment.default_schema = nil
    end

    def next_db
      @x ||= 0
      "db%d" % @x += 1
    end

    def drop_schema(schema)
      ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE") rescue true
    end

    # Use this if you don't want to import schema.rb etc... but need the postgres schema to exist
    # basically for speed purposes
    def create_schema(schema)
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema}")
    end

    def load_schema
      silence_stream(STDOUT){ load(Rails.root.join('db', 'schema.rb')) }
    end

    def migrate
      ActiveRecord::Migrator.migrate(Rails.root + ActiveRecord::Migrator.migrations_path)
    end

    def rollback
      ActiveRecord::Migrator.rollback(Rails.root + ActiveRecord::Migrator.migrations_path)
    end

  end
end