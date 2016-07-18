require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant
    def self.mysql2_adapter(config)
      if Apartment.use_schemas
        Adapters::Mysql2Adapter.new(config)
      else
        Adapters::Mysql2ConnectionAdapter.new(config)
      end
    end
  end

  module Adapters
    class Mysql2ConnectionAdapter < AbstractAdapter
      def initialize(config)
        super

        @default_tenant = config[:database]
        reset
      end

      def rescue_from
        Mysql2::Error
      end
    end

    class Mysql2Adapter < AbstractAdapter
      def initialize(config)
        super

        @default_tenant = config[:database]
        reset
      end

      def local_connect(klass, tenant)
        klass.connection.execute "use `#{environmentify(tenant)}`"
      end

      def rescue_from
        Mysql2::Error
      end
    end
  end
end