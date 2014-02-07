require 'apartment/database'

module Apartment
  module Migrator

    extend self

    # Migrate to latest
    def migrate(database)
      Database.process(database) do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil

        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, version) do |migration|
          ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
        end
      end
    end

    # Migrate up/down to a specific version
    def run(direction, database, version)
      Database.process(database) do
        ActiveRecord::Migrator.run(direction, ActiveRecord::Migrator.migrations_paths, version)
      end
    end

    # rollback latest migration `step` number of times
    def rollback(database, step = 1)
      Database.process(database) do
        ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
      end
    end
  end
end
