require 'active_support/core_ext/module/delegation'

module Apartment

  #   The main entry point to Apartment functions
  #
  module Database

    extend self

    delegate :create, :current_database, :current, :drop, :process, :process_excluded_models, :reset, :seed, :switch, :to => :adapter

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
        if config[:adapter].eql?('jdbc')
          if config[:driver] =~ /mysql/
            adapter_method = 'jdbc_mysql_adapter'
          elsif config[:driver] =~ /postgresql/
            adapter_method = 'jdbc_postgresql_adapter'
          elsif config[:driver] =~ /jtds/
            adapter_method = 'jdbc_sqlserver_adapter'
          end
        end

        begin
          require "apartment/adapters/abstract_jdbc_adapter" if config[:adapter].eql?('jdbc')
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
    def reload!
      Thread.current[:apartment_adapter] = nil
      @config = nil
    end

    private

    #   Fetch the rails database configuration
    #
    def config
      @config ||= Rails.configuration.database_configuration[Rails.env].symbolize_keys
    end

  end

end