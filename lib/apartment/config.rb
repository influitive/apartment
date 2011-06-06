module Apartment
  require 'ostruct'
  
  config_file = File.join(Rails.root, "config/apartment.yml")
  config = {
    :excluded_models => ["User"],
		:use_postgres_schemas => true
	}
					 	
	Config = OpenStruct.new config.merge(YAML.load_file(config_file)) if File.exists? config_file
end
