require 'active_support/core_ext/module/delegation'

module Apartment
  
  #   The main entry point to Apartment functions
	module Database
	  
	  extend self

    # pass these methods to our adapter
    delegate :create, :current_database, :drop, :process, :process_excluded_models, :reset, :seed, :switch, :to => :adapter
    
    # allow for config dependency injection
    attr_writer :config

    #   Fetch the proper multi-tenant adapter based on Rails config
    # 
    #   @return {subclass of Apartment::AbstractAdapter}
    # 
    def adapter
	    @adapter ||= begin
		    adapter_method = "#{config[:adapter]}_adapter"
		    
		    begin
          require "apartment/adapters/#{adapter_method}"
        rescue LoadError => e
          raise "The adapter `#{config[:adapter]}` is not yet supported"
        end

        unless respond_to?(adapter_method)
          raise AdapterNotFound, "database configuration specifies nonexistent #{config[:adapter]} adapter"
        end
      
        send(adapter_method, config)
      end
    end
    
    #   Initialize Apartment config options such as excluded_models
    # 
	  def init
	    process_excluded_models
    end
    
    #   Reset config and adapter so they are reloaded
    # 
    def reload!
      @adapter = nil
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