require 'apartment/adapters/abstract_adapter'

module Apartment
  module Database

    def self.postgresql_adapter(config)
      Apartment.use_schemas ?
        Adapters::PostgresqlSchemaAdapter.new(config) :
        Adapters::PostgresqlAdapter.new(config)
    end
  end

  module Adapters
    # Default adapter when not using Postgresql Schemas
    class PostgresqlAdapter < AbstractAdapter

      def drop(tenant)
        # Apartment.connection.drop_database note that drop_database will not throw an exception, so manually execute
        Apartment.connection.execute(%{DROP DATABASE "#{tenant}"})

      rescue *rescuable_exceptions
        raise DatabaseNotFound, "The tenant #{tenant} cannot be found"
      end

    private

      def rescue_from
        PGError
      end
    end

    # Separate Adapter for Postgresql when using schemas
    class PostgresqlSchemaAdapter < AbstractAdapter

      def initialize(config)
        super

        reset
      end

      #   Drop the tenant
      #
      #   @param {String} tenant Database (schema) to drop
      #
      def drop(tenant)
        Apartment.connection.execute(%{DROP SCHEMA "#{tenant}" CASCADE})

      rescue *rescuable_exceptions
        raise SchemaNotFound, "The schema #{tenant.inspect} cannot be found."
      end

      #   Reset search path to default search_path
      #   Set the table_name to always use the default namespace for excluded models
      #
      def process_excluded_models
        Apartment.excluded_models.each do |excluded_model|
          excluded_model.constantize.tap do |klass|
            # some models (such as delayed_job) seem to load and cache their column names before this,
            # so would never get the default prefix, so reset first
            klass.reset_column_information

            # Ensure that if a schema *was* set, we override
            table_name = klass.table_name.split('.', 2).last

            klass.table_name = "#{Apartment.default_schema}.#{table_name}"
          end
        end
      end

      #   Reset schema search path to the default schema_search_path
      #
      #   @return {String} default schema search path
      #
      def reset
        @current_tenant = Apartment.default_schema
        Apartment.connection.schema_search_path = full_search_path
      end

      def current_tenant
        @current_tenant || Apartment.default_schema
      end

    protected

      #   Set schema search path to new schema
      #
      def connect_to_new(tenant = nil)
        return reset if tenant.nil?
        raise ActiveRecord::StatementInvalid.new("Could not find schema #{tenant}") unless Apartment.connection.schema_exists? tenant

        @current_tenant = tenant.to_s
        Apartment.connection.schema_search_path = full_search_path

      rescue *rescuable_exceptions
        raise SchemaNotFound, "One of the following schema(s) is invalid: #{tenant}, #{full_search_path}"
      end

      #   Create the new schema
      #
      def create_tenant(tenant)
        Apartment.connection.execute(%{CREATE SCHEMA "#{tenant}"})

      rescue *rescuable_exceptions
        raise SchemaExists, "The schema #{tenant} already exists."
      end

    private

      #   Generate the final search path to set including persistent_schemas
      #
      def full_search_path
        persistent_schemas.map(&:inspect).join(", ")
      end

      def persistent_schemas
        [@current_tenant, Apartment.persistent_schemas].flatten
      end
    end
  end
end
