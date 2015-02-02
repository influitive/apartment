require "apartment/adapters/abstract_jdbc_adapter"

module Apartment

  module Tenant
    def self.jdbc_mysql_adapter(config)
      Adapters::JDBCMysqlAdapter.new config
    end
  end

  module Adapters
    class JDBCMysqlAdapter < AbstractJDBCAdapter

      protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super
      rescue TenantNotFound
        Apartment::Tenant.reset
        raise TenantNotFound, "Cannot find database #{environmentify(database)}"
      end
    end
  end
end
