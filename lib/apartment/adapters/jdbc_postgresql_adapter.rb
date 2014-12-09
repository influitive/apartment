require 'apartment/adapters/postgresql_adapter'

module Apartment
  module Tenant

    def self.jdbc_postgresql_adapter(config)
      Apartment.use_schemas ?
        Adapters::JDBCPostgresqlSchemaAdapter.new(config) :
        Adapters::JDBCPostgresqlAdapter.new(config)
    end
  end

  module Adapters

    # Default adapter when not using Postgresql Schemas
    class JDBCPostgresqlAdapter < PostgresqlAdapter

    protected

      def create_tenant(tenant)
        # There is a bug in activerecord-jdbcpostgresql-adapter (1.2.5) that will cause
        # an exception if no options are passed into the create_database call.
        Apartment.connection.create_database(environmentify(tenant), { :thisisahack => '' })

      rescue *rescuable_exceptions
        raise TenantExists, "The tenant #{environmentify(tenant)} already exists."
      end

      #   Return a new config that is multi-tenanted
      #
      def multi_tenantify(tenant)
        @config.clone.tap do |config|
          config[:url] = "#{config[:url].gsub(/(\S+)\/.+$/, '\1')}/#{environmentify(tenant)}"
        end
      end

    private

      def rescue_from
        ActiveRecord::JDBCError
      end
    end

    # Separate Adapter for Postgresql when using schemas
    class JDBCPostgresqlSchemaAdapter < PostgresqlSchemaAdapter

      #   Set schema search path to new schema
      #
      def connect_to_new(tenant = nil)
        return reset if tenant.nil?
        raise ActiveRecord::StatementInvalid.new("Could not find schema #{tenant}") unless Apartment.connection.all_schemas.include? tenant.to_s

        @current = tenant.to_s
        Apartment.connection.schema_search_path = full_search_path

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise TenantNotFound, "One of the following schema(s) is invalid: #{full_search_path}"
      end

    private

      def rescue_from
        ActiveRecord::JDBCError
      end
    end
  end
end
