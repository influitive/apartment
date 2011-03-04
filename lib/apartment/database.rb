
module Apartment
	class Database
		def self.switch(database)
			
			config = get_default_database
			
			if database.nil?
				ActiveRecord::Base.establish_connection(config)
				return
			end

			switched_config = multi_tenantify(config, database)
			
			puts switched_config.to_yaml
			
			ActiveRecord::Base.establish_connection(switched_config)
			
			puts Apartment::Config.excluded_models
			
			Apartment::Config.excluded_models.each do |m|
				klass = Kernel
				m.split("::").each do |i|
					klass = klass.const_get(i)
				end
				
				raise "Excluded class #{klass} could not be found." if klass.nil?
				
				puts "Excluding class #{m}"
				
				klass.establish_connection(config)
			end	
		end
		
		def self.create(database)
			if config["adapter"] == "postgresql"
				ActiveRecord::Base.connection.execute('create table schema_migrations(version varchar(255))')
			end
			
			
			migrate(database)
		end
		
		def self.migrate(database)
			
			config = get_default_database
			switched_config = multi_tenantify(config, database)
			
			ActiveRecord::Base.establish_connection(switched_config)
			
			
			ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db', 'migrate'))
			
			ActiveRecord::Base.establish_connection(config)
		end
		
		protected
			def self.get_default_database
				Rails.configuration.database_configuration[Rails.env]
			end
			
			def self.multi_tenantify(configuration, database)
				new_config = configuration.clone
				
				if new_config['adapter'] == "postgresql"  
					new_config['schema_search_path'] = database
				else
					new_config['database'] = new_config['database'].gsub(Rails.env.to_s, "#{database}_#{Rails.env}")
				end
				
				new_config
			end
	end
	
end