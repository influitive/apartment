module Apartment
  
  module Database
    
    def self.postgresql_adapter(config)
      Apartment.use_postgres_schemas ? 
        Adapters::PostgresqlSchemaAdapter.new(config, :schema_search_path => ActiveRecord::Base.connection.schema_search_path) :
        Adapters::PostgresqlAdapter.new(config)
    end
  end
  
  module Adapters
    
    # Default adapter when not using Postgresql Schemas
    class PostgresqlAdapter < AbstractAdapter
    end
    
    # Separate Adapter for Postgresql when using schemas
    class PostgresqlSchemaAdapter < AbstractAdapter
      
      # Set schema path or connect to new db
	    def connect_to_new(database = nil)
	      puts ">> connect_to_new"
	      puts "database: #{database}"
	      puts "caller: #{caller.inspect}"
	      return reset if database.nil?
	      
    		ActiveRecord::Base.connection.schema_search_path = sanitize(database)
      rescue ActiveRecord::StatementInvalid => e
        raise SchemaNotFound, e
			end
			
			def create(database)
			  puts ">> #{__method__}"
			  database = sanitize(database)   # remove any invalid chars (non-alphanumeric)
  		  ActiveRecord::Base.connection.execute("CREATE SCHEMA #{database}")

  		  process(database) do
  		    puts ">> process"
    			import_database_schema

          # Seed data if appropriate
          seed_data if Apartment.seed_after_create
  			end
  		rescue ActiveRecord::StatementInvalid => e
  		  puts "schema exists!!"
  		  raise SchemaExists, e
      end
			
			def reset
    		ActiveRecord::Base.connection.schema_search_path = @defaults[:schema_search_path]
  	  end
  	  
  	  def current_database
  	    ActiveRecord::Base.connection.schema_search_path
	    end
      
    end
    
  end
end