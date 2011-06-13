module Apartment

  module Config
    
    extend self
    
    @default_config = {
      :excluded_models => [],
      :use_postgres_schemas => true
    }
  	
    # check config for attribute (method), fallback to super method_missing
    def method_missing(method)
      config[method] || super
    end
    
    def reload
      @config = nil
      config
    end
    
  	protected
  	
  	def config
  	  @config ||= begin
  	    @default_config.clone.tap do |config|
  	      config.merge!(YAML.load_file(config_file).symbolize_keys) if File.exists?(config_file)
	      end
	    end
	  end

  	def config_file
  	  File.join(Rails.root, "config/apartment.yml")
    end
    
  end
  
end
