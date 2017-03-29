module ActiveRecord
  class Schema < Migration::Current
    def define(info, &block) # :nodoc:
      instance_eval(&block)

      if info[:version].present?
        initialize_schema_migrations_table
        connection.assume_migrated_upto_version(info[:version], migrations_paths)
      end

      ActiveRecord::InternalMetadata.create_table
      if ActiveRecord::InternalMetadata.connection.respond_to?("schema_search_path")
        puts "*** IMD SP: #{ActiveRecord::InternalMetadata.connection.schema_search_path}"
        puts "*** IMD CS: #{ActiveRecord::InternalMetadata.connection.select_value('select current_schema()')}"
      end
      before = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      ActiveRecord::InternalMetadata[:environment] = ActiveRecord::Migrator.current_environment
      ActiveRecord::Base.logger = before
    end
  end

  class InternalMetadata < ActiveRecord::Base
    def self.create_table
      if original_table_exists?
        connection.rename_table(original_table_name, table_name)
      end
      te = table_exists?
      puts "*** table exists? #{te}"
      unless te
        key_options = connection.internal_string_options_for_primary_key

        puts "*** creating table: #{table_name}"
        puts "*** method loc: #{connection.method(:create_table).source_location}"
        connection.create_table(table_name, id: false) do |t|
          t.string :key, key_options
          t.string :value
          t.timestamps
        end

        puts "** exists now? #{table_exists?}"
      end
    end
  end

  module ConnectionAdapters
    class AbstractAdapter
      def create_table(table_name, comment: nil, **options)
        puts " *** creating #{table_name}"
        td = create_table_definition table_name, options[:temporary], options[:options], options[:as], comment: comment

        if options[:id] != false && !options[:as]
          pk = options.fetch(:primary_key) do
            Base.get_primary_key table_name.to_s.singularize
          end

          if pk.is_a?(Array)
            td.primary_keys pk
          else
            td.primary_key pk, options.fetch(:id, :primary_key), options
          end
        end

        yield td if block_given?

        if options[:force] && data_source_exists?(table_name)
          drop_table(table_name, options)
        end

        result = execute schema_creation.accept td

        puts "*** #{result.inspect}"

        unless supports_indexes_in_create?
          td.indexes.each do |column_name, index_options|
            add_index(table_name, column_name, index_options)
          end
        end

        if supports_comments? && !supports_comments_in_create?
          change_table_comment(table_name, comment) if comment.present?

          td.columns.each do |column|
            change_column_comment(table_name, column.name, column.comment) if column.comment.present?
          end
        end

        result
      end

      class SchemaCreation
        private
          def visit_TableDefinition(o)
            create_sql = "CREATE#{' TEMPORARY' if o.temporary} TABLE #{quote_table_name(o.name)} "

            statements = o.columns.map { |c| accept c }
            statements << accept(o.primary_keys) if o.primary_keys

            if supports_indexes_in_create?
              statements.concat(o.indexes.map { |column_name, options| index_in_create(o.name, column_name, options) })
            end

            if supports_foreign_keys?
              statements.concat(o.foreign_keys.map { |to_table, options| foreign_key_in_create(o.name, to_table, options) })
            end

            create_sql << "(#{statements.join(', ')})" if statements.present?
            add_table_options!(create_sql, table_options(o))
            create_sql << " AS #{@conn.to_sql(o.as)}" if o.as
            puts "**** #{create_sql}"
            create_sql
          end
      end
    end

    class PostgreSQLAdapter < AbstractAdapter
      def data_source_exists?(name)
        name = PostgreSQL::Utils.extract_schema_qualified_name(name.to_s)
        return false unless name.identifier

        if name.identifier == "ar_internal_metadata"
          puts "*** name.schema: #{name.schema}"
          puts "*** select search path: #{select_value('SHOW search_path', 'SCHEMA')}"
          puts "*** schema_search_path: #{schema_search_path}"

          tables = select_values(<<-SQL, 'SCHEMA')
              SELECT *
              FROM pg_class c
              LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
              WHERE c.relkind IN ('r','v','m') -- (r)elation/table, (v)iew, (m)aterialized view
              AND c.relname = '#{name.identifier}'
              AND n.nspname = #{name.schema ? "'#{name.schema}'" : 'ANY (current_schemas(false))'}
          SQL

          puts "*** tables: #{tables.inspect}"
        end

        select_value(<<-SQL, 'SCHEMA').to_i > 0
            SELECT COUNT(*)
            FROM pg_class c
            LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relkind IN ('r','v','m') -- (r)elation/table, (v)iew, (m)aterialized view
            AND c.relname = '#{name.identifier}'
            AND n.nspname = #{name.schema ? "'#{name.schema}'" : 'ANY (current_schemas(false))'}
        SQL
      end
    end
  end
end
