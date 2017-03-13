require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class Mysql2Adapter < AbstractMysqlAdapter
      def data_source_exists?(table_name)
        return false unless table_name.present?

        schema, name = extract_schema_qualified_name_patched(table_name)

        sql = "SELECT table_name FROM information_schema.tables"
        sql << " WHERE table_schema = #{schema} AND table_name = #{name}"

        select_values(sql, "SCHEMA").any?
      end

      def extract_schema_qualified_name_patched(string)
        schema, name = string.to_s.scan(/[^`.\s]+|`[^`]*`/).map { |s| quote(s) }
        schema, name = "DATABASE()", schema unless name
        [schema, name]
      end
    end
  end
end
