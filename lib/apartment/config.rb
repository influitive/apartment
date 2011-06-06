require 'active_support/hash_with_indifferent_access'

module Apartment

  module Config
    
    extend self
    
    @default_config = {
      :excluded_models => ["User"],
  		:use_postgres_schemas => true
  	}
  	
    # Always query from config object, fallback to super method_missing
    def method_missing(method)
      config[method] || super
    end

  	protected
  	
  	def config
  	  @config ||= begin
  	    @default_config.merge!(YAML.load_file(config_file).symbolize_keys) if File.exists?(config_file)
  	    
  	    @default_config
	    end
	  end

  	def config_file
  	  File.join(Rails.root, "config/apartment.yml")
    end
    
  end
  
end
