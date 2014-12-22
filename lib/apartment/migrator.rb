require 'apartment/tenant'

module Apartment
  module Migrator

    extend self

    # Migrate to latest
    def migrate(database)
      Tenant.switch(database) do
        version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil

        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, version) do |migration|
          ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
        end
      end
    end

    # Migrate up/down to a specific version
    def run(direction, database, version)
      Tenant.switch(database) do
        ActiveRecord::Migrator.run(direction, ActiveRecord::Migrator.migrations_paths, version)
      end
    end

    # rollback latest migration `step` number of times
    def rollback(database, step = 1)
      Tenant.switch(database) do
        ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_paths, step)
      end
    end
  end
end
