# frozen_string_literal: true

module Apartment
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      # NOTE: key can either be an array of symbols or a single value.
      # E.g. If we run the following query:
      # `Setting.find_by(key: 'something', value: 'amazing')` key will have an array of symbols: `[:key, :something]`
      # while if we run:
      # `Setting.find(10)` key will have the value 'id'
      def cached_find_by_statement(key, &block)
        # Modifying the cache key to have a reference to the current tenant,
        # so the cached statement is referring only to the tenant in which we've
        # executed this
        cache_key = if key.is_a? String
                      "#{Apartment::Tenant.current}_#{key}"
                    else
                      # NOTE: In Rails 6.0.4 we start receiving an ActiveRecord::Reflection::BelongsToReflection
                      # as the key, which wouldn't work well with an array.
                      [Apartment::Tenant.current] + Array.wrap(key)
                    end
        cache = @find_by_statement_cache[connection.prepared_statements]
        cache.compute_if_absent(cache_key) { ActiveRecord::StatementCache.create(connection, &block) }
      end
    end
  end
end
