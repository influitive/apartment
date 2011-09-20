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
      
      #   Set the table_name to always use the public namespace for excluded models
      # 
      def process_excluded_models
		    
  	    Apartment.excluded_models.each do |excluded_model|
  	      # some models (such as delayed_job) seem to load and cache their column names before this, 
          # so would never get the public prefix, so reset first
  	      excluded_model.reset_column_information

          # Ensure that if a schema *was* set, we override
  	      table_name = excluded_model.table_name.split('.', 2).last

          # Not sure why, but Delayed::Job somehow ignores table_name_prefix...  so we'll just manually set table name instead
  				excluded_model.table_name = "public.#{table_name}"
  			end
      end
  	  
      #   Reset schema search path to the default schema_search_path
      # 
      #   @return {String} default schema search path
      # 
			def reset
    		ActiveRecord::Base.connection.schema_search_path = @defaults[:schema_search_path]
  	  end
  	  
    end
    
  end
end