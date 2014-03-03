require 'apartment/database'

module Apartment
  module Migrator

    extend self

    # Migrate to latest
    def migrate(database)
      Database.process(database, true) do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil

        ActiveRecord::Migrator.migrate(migration_paths(database), version) do |migration|
          ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
        end
        Database.dump(database)
      end
    end

    # Migrate up/down to a specific version
    def run(direction, database, version)
      Database.process(database, true) do
        ActiveRecord::Migrator.run(direction, migration_paths(database), version)
        Database.dump(database)
      end
    end

    # rollback latest migration `step` number of times
    def rollback(database, step = 1)
      Database.process(database, true) do
        ActiveRecord::Migrator.rollback(migration_paths(database), step)
        Database.dump(database)
      end
    end

    private

    def migration_paths(tenant)
      paths = [Apartment.migration_path]
      paths << "#{Apartment.migration_path}/../#{tenant}" if File.exists?("#{Apartment.migration_path}/../#{tenant}")
      paths
    end

  end
end
