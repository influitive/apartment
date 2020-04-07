# frozen_string_literal: true

module Apartment
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def arel_table
        final_table_name = Apartment.table_name_with_tenant(table_name)
        return @arel_table if @arel_table && @arel_table.name == final_table_name

        @arel_table = Arel::Table.new(final_table_name, type_caster: type_caster)
      end
    end
  end
end
