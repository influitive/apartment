# frozen_string_literal: true

require 'apartment/adapters/postgresql_adapter'

module Apartment
  # JDBC helper to decide wether to use JDBC Postgresql Adapter or JDBC Postgresql Adapter with Schemas
  module Tenant
    def self.jdbc_postgresql_adapter(config)
      if Apartment.use_schemas
        Adapters::JDBCPostgresqlSchemaAdapter.new(config)
      else
        Adapters::JDBCPostgresqlAdapter.new(config)
      end
    end
  end

  module Adapters
    # Default adapter when not using Postgresql Schemas
    class JDBCPostgresqlAdapter < PostgresqlAdapter
      private

      def multi_tenantify_with_tenant_db_name(config, tenant)
        config[:url] = "#{config[:url].gsub(%r{(\S+)/.+$}, '\1')}/#{environmentify(tenant)}"
      end

      def create_tenant_command(conn, tenant)
        conn.create_database(environmentify(tenant), thisisahack: '')
      end

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
        raise ActiveRecord::StatementInvalid, "Could not find schema #{tenant}" unless schema_exists?(tenant)

        @current = tenant.is_a?(Array) ? tenant.map(&:to_s) : tenant.to_s
        Apartment.connection.schema_search_path = full_search_path
      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise TenantNotFound, "One of the following schema(s) is invalid: #{full_search_path}"
      end

      private

      def tenant_exists?(tenant)
        return true unless Apartment.tenant_presence_check

        Apartment.connection.all_schemas.include? tenant
      end

      def rescue_from
        ActiveRecord::JDBCError
      end
    end
  end
end
