require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant
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
        raise TenantNotFound,
          "The tenant #{environmentify(tenant)} cannot be found." unless File.exist?(database_file(tenant))

        File.delete(database_file(tenant))
      end

      def current
        File.basename(Apartment.connection.instance_variable_get(:@config)[:database], '.sqlite3')
      end

    protected

      def connect_to_new(tenant)
        raise TenantNotFound,
          "The tenant #{environmentify(tenant)} cannot be found." unless File.exist?(database_file(tenant))

        super database_file(tenant)
      end

      def create_tenant(tenant)
        raise TenantExists,
          "The tenant #{environmentify(tenant)} already exists." if File.exist?(database_file(tenant))

        begin
          f = File.new(database_file(tenant), File::CREAT)
        ensure
          f.close
        end
      end

    private

      def database_file(tenant)
        "#{@default_dir}/#{environmentify(tenant)}.sqlite3"
      end
    end
  end
end
