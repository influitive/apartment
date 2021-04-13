# frozen_string_literal: true

require 'apartment/adapters/abstract_adapter'

module Apartment
  module Tenant
    def self.postgresql_adapter(config)
      adapter = Adapters::PostgresqlAdapter
      adapter = Adapters::PostgresqlSchemaAdapter if Apartment.use_schemas
      adapter = Adapters::PostgresqlSchemaFromSqlAdapter if Apartment.use_sql && Apartment.use_schemas
      adapter.new(config)
    end
  end

  module Adapters
    # Default adapter when not using Postgresql Schemas
    class PostgresqlAdapter < AbstractAdapter
      private

      def rescue_from
        PG::Error
      end
    end

    # Separate Adapter for Postgresql when using schemas
    class PostgresqlSchemaAdapter < AbstractAdapter
      def initialize(config)
        super

        reset
      end

      def default_tenant
        @default_tenant = Apartment.default_tenant || 'public'
      end

      #   Reset schema search path to the default schema_search_path
      #
      #   @return {String} default schema search path
      #
      def reset
        @current = default_tenant
        Apartment.connection.schema_search_path = full_search_path
        reset_sequence_names
      end

      def init
        super
        Apartment.connection.schema_search_path = full_search_path
      end

      def current
        @current || default_tenant
      end

      protected

      def process_excluded_model(excluded_model)
        excluded_model.constantize.tap do |klass|
          # Ensure that if a schema *was* set, we override
          table_name = klass.table_name.split('.', 2).last

          klass.table_name = "#{default_tenant}.#{table_name}"
        end
      end

      def drop_command(conn, tenant)
        conn.execute(%(DROP SCHEMA "#{tenant}" CASCADE))
      end

      #   Set schema search path to new schema
      #
      def connect_to_new(tenant = nil)
        return reset if tenant.nil?
        raise ActiveRecord::StatementInvalid, "Could not find schema #{tenant}" unless schema_exists?(tenant)

        @current = tenant.is_a?(Array) ? tenant.map(&:to_s) : tenant.to_s
        Apartment.connection.schema_search_path = full_search_path

        # When the PostgreSQL version is < 9.3,
        # there is a issue for prepared statement with changing search_path.
        # https://www.postgresql.org/docs/9.3/static/sql-prepare.html
        Apartment.connection.clear_cache! if postgresql_version < 90_300
        reset_sequence_names
      rescue *rescuable_exceptions
        raise TenantNotFound, "One of the following schema(s) is invalid: \"#{tenant}\" #{full_search_path}"
      end

      private

      def tenant_exists?(tenant)
        return true unless Apartment.tenant_presence_check

        Apartment.connection.schema_exists?(tenant)
      end

      def create_tenant_command(conn, tenant)
        # NOTE: This was causing some tests to fail because of the database strategy for rspec
        if ActiveRecord::Base.connection.open_transactions.positive?
          conn.execute(%(CREATE SCHEMA "#{tenant}"))
        else
          schema = %(BEGIN;
          CREATE SCHEMA "#{tenant}";
          COMMIT;)

          conn.execute(schema)
        end
      rescue *rescuable_exceptions => e
        rollback_transaction(conn)
        raise e
      end

      def rollback_transaction(conn)
        conn.execute('ROLLBACK;')
      end

      #   Generate the final search path to set including persistent_schemas
      #
      def full_search_path
        persistent_schemas.map(&:inspect).join(', ')
      end

      def persistent_schemas
        [@current, Apartment.persistent_schemas].flatten
      end

      def postgresql_version
        # ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#postgresql_version is
        # public from Rails 5.0.
        Apartment.connection.send(:postgresql_version)
      end

      def reset_sequence_names
        # sequence_name contains the schema, so it must be reset after switch
        # There is `reset_sequence_name`, but that method actually goes to the database
        # to find out the new name. Therefore, we do this hack to only unset the name,
        # and it will be dynamically found the next time it is needed
        descendants_to_unset = ActiveRecord::Base.descendants
                                                 .select { |c| c.instance_variable_defined?(:@sequence_name) }
                                                 .reject do |c|
                                                   c.instance_variable_defined?(:@explicit_sequence_name) &&
                                                     c.instance_variable_get(:@explicit_sequence_name)
                                                 end
        descendants_to_unset.each do |c|
          # NOTE: due to this https://github.com/rails-on-services/apartment/issues/81
          # unreproduceable error we're checking before trying to remove it
          c.remove_instance_variable :@sequence_name if c.instance_variable_defined?(:@sequence_name)
        end

      def schema_exists?(schemas)
        [*schemas].all? { |schema| Apartment.connection.schema_exists?(schema.to_s) }
      end
    end

    # Another Adapter for Postgresql when using schemas and SQL
    class PostgresqlSchemaFromSqlAdapter < PostgresqlSchemaAdapter
      PSQL_DUMP_BLACKLISTED_STATEMENTS = [
        /SET search_path/i,                           # overridden later
        /SET lock_timeout/i,                          # new in postgresql 9.3
        /SET row_security/i,                          # new in postgresql 9.5
        /SET idle_in_transaction_session_timeout/i,   # new in postgresql 9.6
        /CREATE SCHEMA public/i,
        /COMMENT ON SCHEMA public/i

      ].freeze

      def import_database_schema
        preserving_search_path do
          clone_pg_schema
          copy_schema_migrations
        end
      end

      private

      # Re-set search path after the schema is imported.
      # Postgres now sets search path to empty before dumping the schema
      # and it mut be reset
      #
      def preserving_search_path
        search_path = Apartment.connection.execute('show search_path').first['search_path']
        yield
        Apartment.connection.execute("set search_path = #{search_path}")
      end

      # Clone default schema into new schema named after current tenant
      #
      def clone_pg_schema
        pg_schema_sql = patch_search_path(pg_dump_schema)
        Apartment.connection.execute(pg_schema_sql)
      end

      # Copy data from schema_migrations into new schema
      #
      def copy_schema_migrations
        pg_migrations_data = patch_search_path(pg_dump_schema_migrations_data)
        Apartment.connection.execute(pg_migrations_data)
      end

      #   Dump postgres default schema
      #
      #   @return {String} raw SQL contaning only postgres schema dump
      #
      def pg_dump_schema
        # Skip excluded tables? :/
        # excluded_tables =
        #   collect_table_names(Apartment.excluded_models)
        #   .map! {|t| "-T #{t}"}
        #   .join(' ')

        # `pg_dump -s -x -O -n #{default_tenant} #{excluded_tables} #{dbname}`

        with_pg_env { `pg_dump -s -x -O -n #{default_tenant} #{dbname}` }
      end

      #   Dump data from schema_migrations table
      #
      #   @return {String} raw SQL contaning inserts with data from schema_migrations
      #
      # rubocop:disable Layout/LineLength
      def pg_dump_schema_migrations_data
        with_pg_env { `pg_dump -a --inserts -t #{default_tenant}.schema_migrations -t #{default_tenant}.ar_internal_metadata #{dbname}` }
      end
      # rubocop:enable Layout/LineLength

      # Temporary set Postgresql related environment variables if there are in @config
      #
      def with_pg_env(&block)
        pghost = ENV['PGHOST']
        pgport = ENV['PGPORT']
        pguser = ENV['PGUSER']
        pgpassword = ENV['PGPASSWORD']

        ENV['PGHOST'] = @config[:host] if @config[:host]
        ENV['PGPORT'] = @config[:port].to_s if @config[:port]
        ENV['PGUSER'] = @config[:username].to_s if @config[:username]
        ENV['PGPASSWORD'] = @config[:password].to_s if @config[:password]

        block.call
      ensure
        ENV['PGHOST'] = pghost
        ENV['PGPORT'] = pgport
        ENV['PGUSER'] = pguser
        ENV['PGPASSWORD'] = pgpassword
      end

      #   Remove "SET search_path ..." line from SQL dump and prepend search_path set to current tenant
      #
      #   @return {String} patched raw SQL dump
      #
      def patch_search_path(sql)
        search_path = "SET search_path = \"#{current}\", #{default_tenant};"

        swap_schema_qualifier(sql)
          .split("\n")
          .select { |line| check_input_against_regexps(line, PSQL_DUMP_BLACKLISTED_STATEMENTS).empty? }
          .prepend(search_path)
          .join("\n")
      end

      def swap_schema_qualifier(sql)
        sql.gsub(/#{default_tenant}\.\w*/) do |match|
          if Apartment.pg_excluded_names.any? { |name| match.include? name }
            match
          else
            match.gsub("#{default_tenant}.", %("#{current}".))
          end
        end
      end

      #   Checks if any of regexps matches against input
      #
      def check_input_against_regexps(input, regexps)
        regexps.select { |c| input.match c }
      end

      #   Collect table names from AR Models
      #
      def collect_table_names(models)
        models.map do |m|
          m.constantize.table_name
        end
      end

      # Convenience method for current database name
      #
      def dbname
        Apartment.connection_config[:database]
      end
    end
  end
end
