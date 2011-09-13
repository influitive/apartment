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
      
      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      # 
      #   @param {String} database Database name
      # 
      def connect_to_new(database)
        super
      rescue PGError => e
        raise DatabaseNotFound, environmentify(database)
		  end
		  
    end
    
    # Separate Adapter for Postgresql when using schemas
    class PostgresqlSchemaAdapter < AbstractAdapter
      
      #   Get the current schema search path
      # 
      #   @return {String} current schema search path
      # 
      def current_database
        ActiveRecord::Base.connection.schema_search_path
      end
      
      #   Drop the database schema
      # 
      #   @param {String} database Database (schema) to drop
      # 
      def drop(database)
        ActiveRecord::Base.connection.execute("DROP SCHEMA #{database} CASCADE")
      rescue ActiveRecord::StatementInvalid => e
        raise SchemaNotFound, e
      end
  	  
      #   Reset search path to default search_path
      # 
			def reset
    		ActiveRecord::Base.connection.schema_search_path = @defaults[:schema_search_path]
  	  end
  	  
  	protected
  	
  	  #   Set schema search path to new schema
      # 
	    def connect_to_new(database = nil)
	      return reset if database.nil?
    		ActiveRecord::Base.connection.schema_search_path = database
    		
      rescue ActiveRecord::StatementInvalid => e
        raise SchemaNotFound, e
			end
  	  
  	  def create_database(database)
  	    ActiveRecord::Base.connection.execute("CREATE SCHEMA #{database}")
  	    
  	  rescue ActiveRecord::StatementInvalid => e
  		  raise SchemaExists, e
      end
      
    end
    
  end
end