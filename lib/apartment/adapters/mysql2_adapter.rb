# frozen_string_literal: true

require 'apartment/adapters/abstract_adapter'

module Apartment
  # Helper module to decide wether to use mysql2 adapter or mysql2 adapter with schemas
  module Tenant
    def self.mysql2_adapter(config)
      if Apartment.use_schemas
        Adapters::Mysql2SchemaAdapter.new(config)
      else
        Adapters::Mysql2Adapter.new(config)
      end
    end
  end

  module Adapters
    # Mysql2 Adapter
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

    # Mysql2 Schemas Adapter
    class Mysql2SchemaAdapter < AbstractAdapter
      def initialize(config)
        super

        @default_tenant = config[:database]
        reset
      end

      #   Reset current tenant to the default_tenant
      #
      def reset
        return unless default_tenant

        Apartment.connection.execute "use `#{default_tenant}`"
      end

      protected

      #   Connect to new tenant
      #
      def connect_to_new(tenant)
        return reset if tenant.nil?

        Apartment.connection.execute "use `#{environmentify(tenant)}`"
      rescue ActiveRecord::StatementInvalid => e
        Apartment::Tenant.reset
        raise_connect_error!(tenant, e)
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
