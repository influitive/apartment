require 'apartment/adapters/abstract_adapter'

module Apartment
  module Database

    def self.mysql2_adapter(config)
      Apartment.use_mysql2_swap_connection_pool_strategy ?
        Adapters::SwapConnectionPoolStrategy::Mysql2Adapter.new(config) :
        Adapters::Mysql2Adapter.new(config)
    end
  end

  module Adapters

    module SwapConnectionPoolStrategy
      class Mysql2Adapter < AbstractAdapter

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
          Apartment::Database.reset
          raise DatabaseNotFound, "Cannot find tenant #{environmentify(tenant)}"
        end
      end
    end

    class Mysql2Adapter < AbstractAdapter
      attr_reader :default_tenant

      def initialize(config)
        super

        @default_tenant = config[:database]
        reset
      end

      #   Reset current_tenant to the default_tenant
      #
      def reset
        Apartment.connection.execute "use #{default_tenant}"
      end

      #   Set the table_name to always use the default tenant for excluded models
      #
      def process_excluded_models
        Apartment.excluded_models.each{ |model| process_excluded_model(model) }
      end

    protected

      #   Set schema current_tenant to new db
      #
      def connect_to_new(tenant)
        return reset if tenant.nil?

        Apartment.connection.execute "use #{environmentify(tenant)}"

      rescue ActiveRecord::StatementInvalid
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find tenant #{environmentify(tenant)}"
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
