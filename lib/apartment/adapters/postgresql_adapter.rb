module Apartment
  
  module Database
    
    def self.postgresql_adapter(config)
      Adapters::PostgresqlAdapter.new config, :schema_search_path => ActiveRecord::Base.connection.schema_search_path   # this is the initial search path before any switches happen
    end
  end
  
  module Adapters
    
    class PostgresqlAdapter < AbstractAdapter
      
      # Set schema path or connect to new db
	    def connect_to_new(database)	      
    		return ActiveRecord::Base.connection.schema_search_path = database if using_schemas?

			  super # if !using_schemas? (implicit)
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
    		return ActiveRecord::Base.connection.schema_search_path = @defaults[:schema_search_path] if using_schemas?

		    super # if !using_schemas?
  	  end
  	  
  	  def current_database
  	    return ActiveRecord::Base.connection.schema_search_path if using_schemas?
  	    
  	    super # if !using_schemas?
	    end
      
    protected
    
      def create_schema(database)
  		  reset
  		  
  		  ActiveRecord::Base.connection.execute("CREATE SCHEMA #{sanitize(database)}")
  		rescue Exception => e
  		  raise SchemaExists, e
  	  end

      def using_schemas?
        Apartment.use_postgres_schemas
      end
			
    end
    
  end
end