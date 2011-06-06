require 'active_support'

module Apartment
	module Database
	  extend self
	  
		def switch(database)
			
			if database.nil?
				ActiveRecord::Base.establish_connection(config)
				return
			end

			switched_config = multi_tenantify(database)
			
			puts switched_config.to_yaml
			
			ActiveRecord::Base.establish_connection(switched_config)
			
			puts Apartment::Config.excluded_models
			
			Apartment::Config.excluded_models.each do |excluded_model|
			  klass = excluded_model.constantize
				
				raise "Excluded class #{klass} could not be found." if klass.nil?
				
				puts "Excluding class #{excluded_model}"
				
				klass.establish_connection(config)
			end	
		end
		
		def create(database)
			
			switched_config = multi_tenantify(database)
			
			ActiveRecord::Base.establish_connection(switched_config)
			
			if config["adapter"] == "postgresql"
				ActiveRecord::Base.connection.execute('create table schema_migrations(version varchar(255))')
			end
			
			migrate(database)
		end
		
		def migrate(database)
			
			switched_config = multi_tenantify(database)
			
			ActiveRecord::Base.establish_connection(switched_config)
			
			ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db', 'migrate'))
			
			ActiveRecord::Base.establish_connection(config)
		end
		
		protected
		
			def get_default_database
				Rails.configuration.database_configuration[Rails.env]
			end
			
			def multi_tenantify(database)
				new_config = config.clone
				
				if new_config['adapter'] == "postgresql"  
					new_config['schema_search_path'] = database
				else
					new_config['database'] = new_config['database'].gsub(Rails.env.to_s, "#{database}_#{Rails.env}")
				end
				
				new_config
			end
			
		private
		
		  def config
		    @config ||= get_default_database
	    end
	    
	end
	
end