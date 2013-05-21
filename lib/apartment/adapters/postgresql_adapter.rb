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

    private

      def rescue_from
        PGError
      end
    end

    # Separate Adapter for Postgresql when using schemas
    class PostgresqlSchemaAdapter < AbstractAdapter

      #   Drop the database schema
      #
      #   @param {String} database Database (schema) to drop
      #
      def drop(database)
        Apartment.connection.execute(%{DROP SCHEMA "#{database}" CASCADE})

      rescue *rescuable_exceptions
        raise SchemaNotFound, "The schema #{database.inspect} cannot be found."
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

            # Not sure why, but Delayed::Job somehow ignores table_name_prefix...  so we'll just manually set table name instead
            klass.table_name = "#{Apartment.default_schema}.#{table_name}"
          end
        end
      end

      #   Reset schema search path to the default schema_search_path
      #
      #   @return {String} default schema search path
      #
      def reset
        @current_database = Apartment.default_schema
        Apartment.connection.schema_search_path = full_search_path
      end

      def current_database
        @current_database || Apartment.default_schema
      end

    protected

      #   Set schema search path to new schema
      #
      def connect_to_new(database = nil)
        return reset if database.nil?
        raise ActiveRecord::StatementInvalid.new unless Apartment.connection.schema_exists? database

        @current_database = database.to_s
        Apartment.connection.schema_search_path = full_search_path

      rescue *rescuable_exceptions
        raise SchemaNotFound, "One of the following schema(s) is invalid: #{full_search_path}"
      end

      #   Create the new schema
      #
      def create_database(database)
        Apartment.connection.execute(%{CREATE SCHEMA "#{database}"})

      rescue *rescuable_exceptions
        raise SchemaExists, "The schema #{database} already exists."
      end

    private

      #   Generate the final search path to set including persistent_schemas
      #
      def full_search_path
        persistent_schemas = Apartment.persistent_schemas.map { |schema| %{"#{schema}"} }.join(', ')
        %{"#{@current_database.to_s}"} + (persistent_schemas.empty? ? "" : ", #{persistent_schemas}")
      end
    end
  end
end
