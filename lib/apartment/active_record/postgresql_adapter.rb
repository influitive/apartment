# frozen_string_literal: true

module Apartment::PostgreSqlAdapterPatch
  def default_sequence_name(table, _column)
    res = super
    schema_prefix = "#{Apartment::Tenant.current}."
    if res&.starts_with?(schema_prefix) && Apartment.excluded_models.none?{|m| m.constantize.table_name == table}
      res.delete_prefix!(schema_prefix)
    end
    res
  end
end

require 'active_record/connection_adapters/postgresql_adapter'

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  include Apartment::PostgreSqlAdapterPatch
end
