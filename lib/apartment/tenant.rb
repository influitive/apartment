require 'forwardable'
require 'apartment/deprecation'

module Apartment
  #   The main entry point to Apartment functions
  #
  module Tenant

    extend self
    extend Forwardable

    def_delegators :adapter, :create, :current_tenant, :current, :current_database, :default_tenant, :drop, :switch, :process_excluded_models, :reset, :seed, :switch!

    attr_writer :config

    #   Initialize Apartment config options such as excluded_models
    #
    def init
      process_excluded_models
    end

    #   Fetch the proper multi-tenant adapter based on Rails config
    #
    #   @return {subclass of Apartment::AbstractAdapter}
    #
    def adapter
      Thread.current[:apartment_adapter] ||= begin
        adapter_method = "#{config[:adapter]}_adapter"

        if defined?(JRUBY_VERSION)
          if config[:adapter] =~ /mysql/
            adapter_method = 'jdbc_mysql_adapter'
          elsif config[:adapter] =~ /postgresql/
            adapter_method = 'jdbc_postgresql_adapter'
          end
        end

        begin
          require "apartment/adapters/#{adapter_method}"
        rescue LoadError
          raise "The adapter `#{adapter_method}` is not yet supported"
        end

        unless respond_to?(adapter_method)
          raise AdapterNotFound, "database configuration specifies nonexistent #{config[:adapter]} adapter"
        end

        send(adapter_method, config)
      end
    end

    #   Reset config and adapter so they are regenerated
    #
    def reload!(config = nil)
      Thread.current[:apartment_adapter] = nil
      @config = config
    end

    private

    #   Fetch the rails database configuration
    #
    def config
      @config ||= Apartment.connection_config
    end
  end

  def self.const_missing(const_name)
    if const_name == :Database
      Apartment::Deprecation.warn "`Apartment::Database` has been deprecated. Use `Apartment::Tenant` instead."
      Tenant
    else
      super
    end
  end
end
