module Apartment
  
  module Database
    
    def self.postgresql_adapter(config)
      Adapters::PostgresqlAdapter.new config, :schema_search_path => ActiveRecord::Base.connection.schema_search_path
    end
  end
  
  module Adapters
    
    class PostgresqlAdapter < AbstractAdapter
      
      # Set schema path or connect to new db
	    def connect_to_new(database)	      
    		return ActiveRecord::Base.connection.schema_search_path = database if using_schemas?

			  super
      rescue ActiveRecord::StatementInvalid => e
        raise SchemaNotFound, e
			end
			
			def create(database)
			  reset
			  
			  # Postgres will (optionally) use 'schemas' instead of actual dbs, create a new schema while connected to main (global) db
        create_schema(database) if using_schemas?
        super(database)
      end
			
			def reset
			  if using_schemas?
    		  ActiveRecord::Base.connection.schema_search_path = @defaults[:schema_search_path]
  		  else
  		    super
		    end
  	  end
      
      protected
      
        def create_schema(database)
    		  reset
    		  
    		  ActiveRecord::Base.connection.execute("CREATE SCHEMA #{sanitize(database)}")
    		rescue Exception => e
    		  puts ">> create_schema threw an exception: #{e}"
    	  end

        def using_schemas?
          Apartment.use_postgres_schemas
        end
			
    end
    
  end
end