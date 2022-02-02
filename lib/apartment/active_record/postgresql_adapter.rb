# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

# NOTE: This patch is meant to remove any schema_prefix appart from the ones for
# excluded models. The schema_prefix would be resolved by apartment's setting
# of search path
module Apartment::PostgreSqlAdapterPatch
  def default_sequence_name(table, _column)
    res = super
    schema_prefix = "#{Apartment::Tenant.current}."

    if res&.starts_with?(schema_prefix)
      if Apartment.excluded_models.none? { |m| m.constantize.table_name == table }
        res.delete_prefix!(schema_prefix)
      else
        res.sub!(schema_prefix, "#{Apartment::Tenant.default_tenant}.")
      end
    end
    res
  end
end

require 'active_record/connection_adapters/postgresql_adapter'

# NOTE: inject this into postgresql adapters
class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  include Apartment::PostgreSqlAdapterPatch
end
# rubocop:enable Style/ClassAndModuleChildren
