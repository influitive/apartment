require 'apartment/adapters/postgresql_adapter'

module Apartment
  module Tenant

    def self.jdbc_postgresql_adapter(config)
      Adapters::JDBCPostgresqlAdapter.new(config)
    end
  end

  module Adapters
    class JDBCPostgresqlAdapter < PostgresqlAdapter

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
