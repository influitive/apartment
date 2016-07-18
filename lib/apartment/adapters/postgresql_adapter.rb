require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant
    def self.postgresql_adapter(config)
      if Apartment.use_schemas
        Adapters::PostgresqlAdapter.new(config)
      else
        Adapters::PostgresqlDatabaseAdapter.new(config)
      end
    end
  end

  module Adapters
    class PostgresqlDatabaseAdapter < AbstractAdapter

      #   The pg database adapter passes `tenant` to `switch_to_host` so it
      #   maintains a separate pool per tenant, which is shared across threads.
      #
      #   The reason it's per tenant is so that with pg you cannot switch
      #   database on a connection (afaict?).
      #
      def conditional_connect(klass, tenant)
        Apartment.switch_to_host(klass, multi_tenantify(tenant, false), tenant)
      end

    private

      def rescue_from
        PGError
      end
    end

    class PostgresqlAdapter < AbstractAdapter
      def initialize(*)
        super

        @original_search_path = Apartment.connection.schema_search_path
        @default_tenant = 'public'
        reset
      end

      #   The regular schema adapter passes `conf[:host]` to `switch_to_host` so
      #   it maintains a separate pool per tenant, which is shared across
      #   threads.
      #
      #   The reason it's per host is so that connections for the same host can
      #   share a pool and just modify the schema search path for that
      #   connection.
      #
      def conditional_connect(klass, tenant)
        conf = multi_tenantify(tenant, false)
        Apartment.switch_to_host(klass, conf, conf[:host])
      end

      def connection_connect(klass, tenant)
        klass.establish_connection(multi_tenantify(tenant, false))
      end

      def local_connect(klass, tenant)
        # handle nil case?
        unless klass.connection.schema_exists?(tenant)
          raise ActiveRecord::StatementInvalid.new("Could not find schema #{tenant}")
        end

        @current = tenant.to_s
        klass.connection.schema_search_path = full_search_path
      rescue *rescuable_exceptions
        raise TenantNotFound, "One of the following schema(s) is invalid: \"#{tenant}\" #{full_search_path}"
      end

      def reset
        @current = default_tenant
        Apartment.connection.schema_search_path = full_search_path
      end

      def current
        @current || default_tenant
      end

    protected

      def drop_command(conn, tenant)
        conn.execute(%{DROP SCHEMA "#{tenant}" CASCADE})
      end

      def create_tenant_command(conn, tenant)
        conn.execute(%{CREATE SCHEMA "#{tenant}"})
      end

      #   Generate the final search path to set including persistent_schemas
      #
      def full_search_path
        persistent_schemas.map(&:inspect).join(", ")
      end

      def persistent_schemas
        [@current] + Apartment.persistent_schemas
      end
    end
  end
end