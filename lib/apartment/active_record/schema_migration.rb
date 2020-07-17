# frozen_string_literal: true

module ActiveRecord
  class SchemaMigration < ActiveRecord::Base # :nodoc:
    class << self
      def table_exists?
        connection.table_exists?(table_name)
      end
    end
  end
end
