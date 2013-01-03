module ::ArJdbc
  module PostgreSQL
    def indexes(table_name, name = nil)
      schemas = schema_search_path.split(/,/).map { |p| quote(p) }.join(',')
      result = select_rows(<<-SQL, name)
          SELECT i.relname, d.indisunique, a.attname, a.attnum, d.indkey
            FROM pg_class t, pg_class i, pg_index d, pg_attribute a,
            generate_series(0,#{multi_column_index_limit - 1}) AS s(i)
           WHERE i.relkind = 'i'
             AND d.indexrelid = i.oid
             AND d.indisprimary = 'f'
             AND t.oid = d.indrelid
             AND t.relname = '#{table_name}'
             AND i.relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (current_schemas(false)) )
             AND a.attrelid = t.oid
             AND d.indkey[s.i]=a.attnum
          ORDER BY i.relname
      SQL

      current_index = nil
      indexes = []

      insertion_order = []
      index_order = nil

      result.each do |row|
        if current_index != row[0]

          (index_order = row[4].split(' ')).each_with_index { |v, i| index_order[i] = v.to_i }
          indexes << ::ActiveRecord::ConnectionAdapters::IndexDefinition.new(table_name, row[0], row[1] == "t", [])
          current_index = row[0]
        end
        insertion_order = row[3]
        ind = index_order.index(insertion_order)
        indexes.last.columns[ind] = row[2]
      end

      indexes
    end

    def schema_search_path=(schema_csv)
      if schema_csv
        execute "SET search_path TO #{schema_csv}"
        @schema_search_path = schema_csv
      end
    end

    # Returns the active schema search path.
    def schema_search_path
      @schema_search_path ||= exec_query('SHOW search_path', 'SCHEMA')[0]['search_path'].gsub(/"\$user",/, '')
    end

    # Returns the current schema name.
    def current_schema
      exec_query('SELECT current_schema', 'SCHEMA')[0]["current_schema"]
    end
  end
end

module Apartment

  module Database

    def self.jdbc_postgresql_adapter(config)
      Apartment.use_postgres_schemas ?
          Adapters::JDBCPostgresqlSchemaAdapter.new(config, :schema_search_path => ActiveRecord::Base.connection.schema_search_path) :
          Adapters::JDBCPostgresqlAdapter.new(config)
    end
  end

  module Adapters

    # Defascheult adapter when not using Postgresql Schemas
    class JDBCPostgresqlAdapter < AbstractJDBCAdapter

      protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super
      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end
    end

    # Separate Adapter for Postgresql when using schemas
    class JDBCPostgresqlSchemaAdapter < AbstractJDBCAdapter

      attr_reader :current_database

      #   Drop the database schema
      #
      #   @param {String} database Database (schema) to drop
      #
      def drop(database)
        Apartment.connection.execute(%{DROP SCHEMA "#{database}" CASCADE})

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
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

      protected

      #   Set schema search path to new schema
      #
      def connect_to_new(database = nil)
        return reset if database.nil?

        @current_database = database.to_s
        Apartment.connection.schema_search_path = full_search_path

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise SchemaNotFound, "One of the following schema(s) is invalid: #{full_search_path}"
      end

      #   Create the new schema
      #
      def create_database(database)
        Apartment.connection.execute(%{CREATE SCHEMA "#{database}"})

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
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