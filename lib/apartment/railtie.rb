require 'rails'

module Apartment
	class Railtie < Rails::Railtie
	  
    # Ensure that active_record is loaded, then run default config
	  initializer 'apartment.configure' do
      # ActiveSupport.on_load(:active_record) do
	    
  	    Apartment.configure do |config|
          config.excluded_models = []
          config.use_postgres_schemas = true
          config.database_names = []
          config.seed_after_create = false
          config.prepend_environment = true
        end
        
      # end
    end
	  
		rake_tasks do
			load 'tasks/apartment.rake'
		end
	end
end
