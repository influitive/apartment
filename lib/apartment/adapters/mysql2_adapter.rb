require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant

    def self.mysql2_adapter(config)
      if ::ActiveRecord::VERSION::MAJOR == 5 && ::ActiveRecord::VERSION::MINOR == 0
        require 'apartment/rails5_patch'
      end

      Apartment.use_schemas ?
        Adapters::Mysql2SchemaAdapter.new(config) :
        Adapters::Mysql2Adapter.new(config)
    end
  end

  module Adapters
    class Mysql2Adapter < AbstractAdapter

      def initialize(config)
        super

        @default_tenant = config[:database]
      end

    protected

      def rescue_from
        Mysql2::Error
      end
    end

    class Mysql2SchemaAdapter < AbstractAdapter
      def initialize(config)
        super

        @default_tenant = config[:database]
        reset
      end

      #   Reset current tenant to the default_tenant
      #
      def reset
        Apartment.connection.execute "use `#{default_tenant}`"
      end

    protected

      #   Connect to new tenant
      #
      def connect_to_new(tenant)
        return reset if tenant.nil?

        Apartment.connection.execute "use `#{environmentify(tenant)}`"

      rescue ActiveRecord::StatementInvalid => exception
        Apartment::Tenant.reset
        raise_connect_error!(tenant, exception)
      end

      def process_excluded_model(model)
        model.constantize.tap do |klass|
          # Ensure that if a schema *was* set, we override
          table_name = klass.table_name.split('.', 2).last

          klass.table_name = "#{default_tenant}.#{table_name}"
        end
      end

      def reset_on_connection_exception?
        true
      end
    end
  end
end
