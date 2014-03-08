require 'apartment/database'

module Apartment
  module Migrator

    extend self

    # Migrate to latest
    def migrate(database)
      ensure_schema_migrations_table_exists(database)
      Database.process(database) do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil

        ActiveRecord::Migrator.migrate(migration_paths(database), version) do |migration|
          ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
        end
      end
      dump_schema(database)
    end

    # Migrate up/down to a specific version
    def run(direction, database, version)
      ensure_schema_migrations_table_exists(database)
      Database.process(database) do
        ActiveRecord::Migrator.run(direction, migration_paths(database), version)
      end
      dump_schema(database)
    end

    # rollback latest migration `step` number of times
    def rollback(database, step = 1)
      ensure_schema_migrations_table_exists(database)
      Database.process(database) do
        ActiveRecord::Migrator.rollback(migration_paths(database), step)
      end
      dump_schema(database)
    end

    private

    def ensure_schema_migrations_table_exists(database)
      Database.process(database, true) do
        ActiveRecord::SchemaMigration.create_table
      end
    end

    def dump_schema(database)
      puts "dump_schema(#{database})"
      Database.process(database, true) do
        Database.dump(database)
      end
    end

    def migration_paths(tenant)
      paths = [Apartment.migration_path]
      paths << "#{Apartment.migration_path}/../#{tenant}" if File.exists?("#{Apartment.migration_path}/../#{tenant}")
      paths
    end

  end
end
