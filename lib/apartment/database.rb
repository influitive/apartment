require 'forwardable'

module Apartment

  #   The main entry point to Apartment functions
  #
  module Database

    extend self
    extend Forwardable

    def_delegators :adapter, :create, :current_database, :current, :drop, :process, :process_excluded_models, :reset, :seed, :switch

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

        begin
          require "apartment/adapters/#{adapter_method}"
        rescue LoadError
          raise "The adapter `#{config[:adapter]}` is not yet supported"
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
      @config ||= Rails.configuration.database_configuration[Rails.env].symbolize_keys
    end

  end

end