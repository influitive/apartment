require 'active_support/core_ext/module/delegation'

module Apartment
	module Database
	  
	  class << self

      # pass these methods to our adapter
      delegate :create, :switch, :reset, :process, :seed, :current_database, :to => :adapter

      # Call init to establish a connection to the public schema on all excluded models
      # This must be done before creating any new schemas or switching
  	  def init
  	    connect_exclusions
      end
      
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
	    
	    def reload!
	      @adapter = nil
	      @config = nil
      end
      
		private
		
		  def connect_exclusions
		    # Establish a connection for each specific excluded model
        # Thus all other models will shared a connection (at ActiveRecord::Base) and we can modify at will
  	    Apartment.excluded_models.each do |excluded_model|
  				excluded_model.establish_connection config
  			end
      end
    
      def config
        @config ||= Rails.configuration.database_configuration[Rails.env].symbolize_keys
      end
    end
	    					
	end
	
end