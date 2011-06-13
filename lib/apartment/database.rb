require 'active_support/core_ext/string/inflections'
require 'active_record'

module Apartment
	module Database
	  extend self
	  
    # Call init to establish a connection to the public schema on all excluded models
    # This must be done before creating any new schemas or switching
	  def init
	    @default_schema_search_path = ActiveRecord::Base.connection.schema_search_path
      # Establish a connection for each specific excluded model
      # Thus all other models will shared a connection (at ActiveRecord::Base) and we can modify at will
	    Config.excluded_models.each do |excluded_model|
			  klass = excluded_model.constantize				
				klass.establish_connection(config)
			end
    end
	  
		def switch(database = nil)
      # Just connect to default db and return
			return reset if database.nil?

      connect_to_new(database)
		end
		
		def reset
		  ActiveRecord::Base.connection.schema_search_path = @default_schema_search_path
	  end
		
    # Create new postgres schema
		def create(database)
      # Postgres will (optionally) use 'schemas' instead of actual dbs, create a new schema while connected to main (global) db
      create_schema(database) if use_schemas?
      # TODO create database if not using schemas
			
			connect_and_reset(database) do
  			import_database_schema
			
  			# Manually init schema migrations table (apparently there were issues with Postgres when this isn't done)
  			ActiveRecord::Base.connection.initialize_schema_migrations_table
			end
		end
		
		def create_schema(database)
		  reset   # ensure that we're on the base connection when creating our schema
		  ActiveRecord::Base.connection.execute("CREATE SCHEMA #{sanitize(database)}")
		rescue Exception => e
		  puts ">> create_schema threw an exception: #{e}"
	  end
		
    # Migrate to latest
		def migrate(database)
			connect_and_reset(database){ ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path) }
		end
		
    # Migrate up to version
		def migrate_up(database, version)
		  connect_and_reset(database){ ActiveRecord::Migrator.run(:up, ActiveRecord::Migrator.migrations_path, version) }
	  end
	  
    # Migrate down to version
    def migrate_down(database, version)
      connect_and_reset(database){ ActiveRecord::Migrator.run(:down, ActiveRecord::Migrator.migrations_path, version) }
    end
	
		def rollback(database, step = 1)
		  connect_and_reset(database){ ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_path, step) }
	  end
	  
		protected
		
		  def connect_and_reset(database)
		    connect_to_new(database)
		    yield if block_given?
		  ensure
  		  reset
	    end
		
		  def import_database_schema
		    file = "#{Rails.root}/db/schema.rb"
        if File.exists?(file)
          load(file)
        else
          abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again}
        end
	    end
	    
      # Are we using postgres schemas
	    def use_schemas?(conf = nil)
	      (conf || config)['adapter'] == "postgresql" && Config.use_postgres_schemas
      end
	    
      # Generate new connection config and connect
	    def connect_to_new(database)
  			ActiveRecord::Base.connection.schema_search_path = database
  		rescue Exception => e
  		  puts "setting schema_search_path threw an exception!!!: #{e.inspect}"  
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
			
			def default_database_config
				Rails.configuration.database_configuration[Rails.env]
			end
			
		  def config
		    @config ||= default_database_config
	    end
	    
      # Remove all non-alphanumeric characters
	    def sanitize(database)
	      database.gsub(/[\W]/,'')
      end
	    
	end
	
end