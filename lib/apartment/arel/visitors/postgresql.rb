# frozen_string_literal: true

module Arel # :nodoc: all
  module Visitors
    class PostgreSQL < Arel::Visitors::ToSql
      private

      # rubocop:disable Naming/MethodName
      # rubocop:disable Naming/MethodParameterName
      def visit_Arel_Table(o, collector)
        if o.table_alias
          collector << quoted_table_name_with_tenant(o.name) << ' ' << quote_table_name(o.table_alias)
        else
          collector << quoted_table_name_with_tenant(o.name)
        end
      end
      # rubocop:enable Naming/MethodParameterName
      # rubocop:enable Naming/MethodName

      def quoted_table_name_with_tenant(table_name)
        # NOTE: Only postgres supports schemas, so prepending tenant name
        # as part of the table name is only available if configuration
        # specifies use_schemas
        if Apartment.allow_prepend_tenant_name && Apartment.use_schemas && !table_name.include?('.')
          quote_table_name("#{Apartment::Tenant.current}.#{table_name}")
        else
          quote_table_name(table_name)
        end
      end
    end
  end
end
