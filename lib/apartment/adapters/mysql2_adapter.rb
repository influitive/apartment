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

      #   Connect to new tenant
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} tenant Tenant name
      #
      def connect_to_new(tenant = nil)
        super
      rescue Mysql2::Error
        Apartment::Tenant.reset
        raise TenantNotFound, "Cannot find tenant #{environmentify(tenant)}"
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

      #   Set the table_name to always use the default tenant for excluded models
      #
      def process_excluded_models
        Apartment.excluded_models.each{ |model| process_excluded_model(model) }
      end

    protected

      #   Connect to new tenant
      #
      def connect_to_new(tenant)
        return reset if tenant.nil?

        Apartment.connection.execute "use `#{environmentify(tenant)}`"

      rescue ActiveRecord::StatementInvalid
        Apartment::Tenant.reset
        raise TenantNotFound, "Cannot find tenant #{environmentify(tenant)}"
      end

      def process_excluded_model(model)
        model.constantize.tap do |klass|
          # Ensure that if a schema *was* set, we override
          table_name = klass.table_name.split('.', 2).last

          klass.table_name = "#{default_tenant}.#{table_name}"
        end
      end
    end
  end
end
