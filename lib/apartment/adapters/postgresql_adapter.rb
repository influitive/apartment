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
      # TODO sanitize method doesn't work with schemas as the default schema uses "$user", stripping out the quotes makes it fail
	    def connect_to_new(database = nil)
	      return reset if database.nil?
    		ActiveRecord::Base.connection.schema_search_path = database
      rescue ActiveRecord::StatementInvalid => e
        raise SchemaNotFound, "The Schema #{database.inspect} cannot be found."
			end
			
			def create(database)
  		  ActiveRecord::Base.connection.execute("CREATE SCHEMA #{database}")

  		  process(database) do
    			import_database_schema

          # Seed data if appropriate
          seed_data if Apartment.seed_after_create
  			end
  		rescue ActiveRecord::StatementInvalid => e
  		  raise SchemaExists, "The schema #{database} already exists."
      end
			
      def current_database
        ActiveRecord::Base.connection.schema_search_path
      end
  	  
			def reset
    		ActiveRecord::Base.connection.schema_search_path = @defaults[:schema_search_path]
  	  end
  	  
    end
    
  end
end