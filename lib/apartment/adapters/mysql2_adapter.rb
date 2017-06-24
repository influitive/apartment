require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant

    def self.mysql2_adapter(config)
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

        super.tap do
          begin
            Apartment.connection.execute "use `#{environmentify(tenant)}`"
          rescue
            Apartment::Tenant.reset
            raise_connect_error!(tenant, exception)
          end
        end
      end

      def process_excluded_model(excluded_model)
        ensure_exclude_table_name(excluded_model.constantize) do
          super
        end
      end

      def ensure_exclude_table_name(model)
        table_name = model.table_name.split('.', 2).last
        yield
      ensure
        model.table_name = "#{default_tenant}.#{table_name}"
      end

      def reset_on_connection_exception?
        true
      end
    end
  end
end
