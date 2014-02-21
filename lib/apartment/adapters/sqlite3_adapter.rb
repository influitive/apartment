require 'apartment/adapters/abstract_adapter'

module Apartment
  module Database
    def self.sqlite3_adapter(config)
      Adapters::Sqlite3Adapter.new(config)
    end
  end

  module Adapters
    class Sqlite3Adapter < AbstractAdapter
      def initialize(config)
        @default_dir = File.expand_path(File.dirname(config[:database]))

        super
      end

      def drop(tenant)
        raise DatabaseNotFound,
          "The tenant #{environmentify(tenant)} cannot be found." unless File.exists?(database_file(tenant))

        File.delete(database_file(tenant))
      end

      def current_tenant
        File.basename(Apartment.connection.instance_variable_get(:@config)[:database], '.sqlite3')
      end

    protected

      def connect_to_new(tenant)
        raise DatabaseNotFound,
          "The tenant #{environmentify(tenant)} cannot be found." unless File.exists?(database_file(tenant))

        super database_file(tenant)
      end

      def create_tenant(tenant)
        raise DatabaseExists,
          "The tenant #{environmentify(tenant)} already exists." if File.exists?(database_file(tenant))

        f = File.new(database_file(tenant), File::CREAT)
        f.close
      end

    private

      def database_file(tenant)
        "#{@default_dir}/#{tenant}.sqlite3"
      end
    end
  end
end
