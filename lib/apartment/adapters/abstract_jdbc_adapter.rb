require 'apartment/adapters/abstract_adapter'

module Apartment
  module Adapters
    class AbstractJDBCAdapter < AbstractAdapter

    private

      def multi_tenantify_with_tenant_db_name(config, tenant)
        config[:url] = "#{config[:url].gsub(/(\S+)\/.+$/, '\1')}/#{environmentify(tenant)}"
      end

      def rescue_from
        ActiveRecord::JDBCError
      end
    end
  end
end
