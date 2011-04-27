module Apartment
  require 'ostruct'
  
  config = {:excluded_models => ["User"],
						:use_postgres_schemas => true
					 }		
	
	if File.exists? "config/apartment.yml"
  	config = config.merge YAML.load_file "config/apartment.yml" 
		Config = OpenStruct.new(config)
	end									
end
