require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant
    def self.sqlserver_adapter(config)
      config['default_schema'] = 'dbo' if config['default_schema'].eql?('public')
      Adapters::SqlserverAdapter.new config
    end
  end

  module Adapters
    class SqlserverAdapter < AbstractAdapter
      private

      def rescue_from
        TinyTds::Error
      end
    end
  end
end
