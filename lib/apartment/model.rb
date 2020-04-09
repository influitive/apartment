# frozen_string_literal: true

module Apartment
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      # NOTE: key is actually an array of keys. E.g. If we run the following
      # query: `Setting.find_by(key: 'something', value: 'amazing')` key will
      # have an array of symbols: `[:key, :something]`
      def cached_find_by_statement(key, &block)
        # Modifying the cache key to have a reference to the current tenant,
        # so the cached statement is referring only to the tenant in which we've
        # executed this
        cache_key = [Apartment::Tenant.current] + key
        cache = @find_by_statement_cache[connection.prepared_statements]
        cache.compute_if_absent(cache_key) { ActiveRecord::StatementCache.create(connection, &block) }
      end
    end
  end
end
