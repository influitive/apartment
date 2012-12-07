module Apartment

  module Database

    def self.postgresql_adapter(config)
      Apartment.use_postgres_schemas ?
        Adapters::PostgresqlSchemaAdapter.new(config) :
        Adapters::PostgresqlAdapter.new(config)
    end
  end

  module Adapters

    # Default adapter when not using Postgresql Schemas
    class PostgresqlAdapter < AbstractAdapter

    protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super
      rescue PGError
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
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

      rescue ActiveRecord::StatementInvalid
        raise SchemaNotFound, "The schema #{database.inspect} cannot be found."
      end

      #   Reset search path to default search_path
      #   Set the table_name to always use the default namespace for excluded models
      #
      def process_excluded_models
        Apartment.excluded_models.each do |excluded_model|
          # Note that due to rails reloading, we now take string references to classes rather than
          # actual object references.  This way when we contantize, we always get the proper class reference
          if excluded_model.is_a? Class
            warn "[Deprecation Warning] Passing class references to excluded models is now deprecated, please use a string instead"
            excluded_model = excluded_model.name
          end

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

        @current_database = database.to_s
        Apartment.connection.schema_search_path = full_search_path

      rescue ActiveRecord::StatementInvalid
        raise SchemaNotFound, "One of the following schema(s) is invalid: #{full_search_path}"
      end

      #   Create the new schema
      #
      def create_database(database)
        Apartment.connection.execute(%{CREATE SCHEMA "#{database}"})

      rescue ActiveRecord::StatementInvalid
        raise SchemaExists, "The schema #{database} already exists."
      end

    private

      #   Generate the final search path to set including persistent_schemas
      #
      def full_search_path
        persistent_schemas = Apartment.persistent_schemas.join(', ')
        @current_database.to_s + (persistent_schemas.empty? ? "" : ", #{persistent_schemas}")
      end
    end
  end
end