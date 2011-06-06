require 'active_support/core_ext/string/inflections'
require 'active_record'

module Apartment
	module Database
	  extend self
	  
		def switch(database)
			
      # Just connect to default db and return
			return ActiveRecord::Base.establish_connection(config) if database.nil?

      connect_to_new(database)
			
			puts "Apartment::Config.excluded_models: #{Apartment::Config.excluded_models}"
			
			Apartment::Config.excluded_models.each do |excluded_model|
			  klass = excluded_model.constantize
				
				raise "Excluded class #{klass} could not be found." if klass.nil?
				
				puts "Excluding class #{excluded_model}"
				
				klass.establish_connection(config)
			end
		end
		
		def create(database)
			
      # Postgres will (optionally) use 'schemas' instead of actual dbs, create a new schema while connected to main (global) db
      ActiveRecord::Base.connection.execute("create schema #{database}") if use_schemas?
      
			connect_to_new(database)
			
			load_database_schema
			
      # Manually init schema migrations table (apparently there were issues with Postgres)
			ActiveRecord::ConnectionAdapters::SchemaStatements.initialize_schema_migrations_table
		end
		
		def migrate(database)
			
			connect_to_new(database)
			
			ActiveRecord::Migrator.migrate(File.join(Rails.root, ActiveRecord::Migrator.migrations_path))
			
			ActiveRecord::Base.establish_connection(config)
		end
		
		protected
		
		  def load_database_schema
		    file = "#{Rails.root}/db/schema.rb"
        if File.exists?(file)
          load(file)
        else
          abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again}
        end
	    end
	    
      # Are we using postgres schemas
	    def use_schemas?(conf)
	      (conf || config)['adapter'] == "postgresql" && Config.use_postgres_schemas
      end
	    
      # Generate new connection config and connect
	    def connect_to_new(database)
	      switched_config = multi_tenantify(database)

  			puts "connecting to db with config: #{switched_config.to_yaml}"

  			ActiveRecord::Base.establish_connection(switched_config)
			end
		
			def multi_tenantify(database)
				new_config = config.clone
				
				if use_schemas?(new_config)
					new_config['schema_search_path'] = database
				else
					new_config['database'] = new_config['database'].gsub(Rails.env.to_s, "#{database}_#{Rails.env}")
				end
				
				new_config
			end
			
			def get_default_database
				Rails.configuration.database_configuration[Rails.env]
			end
			
		private
		
		  def config
		    @config ||= get_default_database
	    end
	    
	end
	
end