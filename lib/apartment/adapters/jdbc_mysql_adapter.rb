require "apartment/adapters/abstract_jdbc_adapter"

module Apartment

  module Tenant
    def self.jdbc_mysql_adapter(config)
      Adapters::JDBCMysqlAdapter.new config
    end
  end

  module Adapters
    class JDBCMysqlAdapter < AbstractJDBCAdapter

      def reset_on_connection_exception?
        true
      end
    end
  end
end
