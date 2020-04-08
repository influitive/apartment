# frozen_string_literal: true

module Apartment
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def cached_find_by_statement(key, &block)
        cache_key = "#{Apartment::Tenant.current}_#{key}".to_sym
        cache = @find_by_statement_cache[connection.prepared_statements]
        cache.compute_if_absent(cache_key) { ActiveRecord::StatementCache.create(connection, &block) }
      end
    end
  end
end
