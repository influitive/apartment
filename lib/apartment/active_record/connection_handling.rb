module ActiveRecord
  module ConnectionHandling
    # Taken from the following and modified as commented below:
    # https://github.com/rails/rails/blob/v5.0.0.1/activerecord/lib/active_record/connection_handling.rb#L47-L57

    def establish_connection(config = nil)
      raise "Anonymous class is not allowed." unless name

      config ||= DEFAULT_ENV.call.to_sym

      # If we pass in a spec, send the tenant (set in Apartment::AbstractAdapter)
      # as the connection name. If spec is not a hash revert to existing behavior.
      spec_name = if config.is_a?(Hash)
                    config.fetch(:tenant, fallback_connection_specification_name)
                  else
                    fallback_connection_specification_name
                  end

      self.connection_specification_name = spec_name

      resolver = ConnectionAdapters::ConnectionSpecification::Resolver.new(Base.configurations)
      spec = resolver.resolve(config).symbolize_keys
      spec[:name] = spec_name

      connection_handler.establish_connection(spec)
    end

    private

    def fallback_connection_specification_name
      self == Base ? 'primary' : name
    end
  end
end
