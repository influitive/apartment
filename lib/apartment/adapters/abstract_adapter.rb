require 'active_record'

module Apartment
  
  module Adapters
  
    class AbstractAdapter
      
      #   @constructor
      #   @param {Hash} config Database config
      #   @param {Hash?} defaults Some default options
      # 
      def initialize(config, defaults = {})
        @config = config
        @defaults = defaults
      end
      
      #   Connect to db, do your biz, switch back to previous db
      # 
      #   @param {String?} database Database or schema to connect to
      # 
      def process(database = nil)
        current_db = current_database
		    switch(database)
		    yield if block_given?
		  ensure
  		  switch(current_db)
	    end
      
      #   Create a new database, import schema, seed if appropriate
      # 
      #   @param {String} database Database name
      # 
  		def create(database)
  		  create_database(database)

  			process(database) do
    			import_database_schema

          # Seed data if appropriate
          seed_data if Apartment.seed_after_create
  			end
  		end
  		
      #   Drop the database
      # 
      #   @param {String} database Database name
      # 
      def drop(database)
        # ActiveRecord::Base.connection.drop_database   note that drop_database will not throw an exception, so manually execute
        ActiveRecord::Base.connection.execute("DROP DATABASE #{environmentify(database)}" )
        
      rescue ActiveRecord::StatementInvalid => e
  		  raise DatabaseNotFound, environmentify(database)
      end
    
      #   Reset the base connection
      # 
      def reset
        ActiveRecord::Base.establish_connection @config
      end
      
      #   Switch to new database or reset
      # 
      #   @param {String?} database Database name
      # 
      def switch(database = nil)
        # Just connect to default db and return
  			return reset if database.nil?

        connect_to_new(database)
  		end

      #   prepend the environment if configured and the environment isn't already there
      # 
      #   @return {String} Database name with environment prepended (if applicable)
      #   @param {String} database Database name
      #   
      def environmentify(database)
        Apartment.prepend_environment && !database.include?(Rails.env) ? "#{Rails.env}_#{database}" : database
  		end
  		
      #   Seed data from Rails seeds
      # 
  		def seed_data
	      load_or_abort("#{Rails.root}/db/seeds.rb")
      end
	    alias_method :seed, :seed_data
      
      #   Get the current database name
      # 
      #   @return {String} current database name
      # 
      def current_database
        ActiveRecord::Base.connection.current_database
      end
      
    protected
    
      #   Create the database
      # 
      #   @param {String} database Database name
      # 
      def create_database(database)
        ActiveRecord::Base.connection.create_database( environmentify(database) )
        
      rescue ActiveRecord::StatementInvalid => e
  		  raise DatabaseExists, environmentify(database)
      end
    
      #   Connect to new database
      # 
      #   @param {String} database Database name
      # 
      def connect_to_new(database)
        ActiveRecord::Base.establish_connection multi_tenantify(database)
        ActiveRecord::Base.connection.active?   # call active? to manually check if this connection is valid
        
      rescue ActiveRecord::StatementInvalid => e
        raise DatabaseNotFound, e
		  end
      
      #   Import database schema
      # 
	    def import_database_schema
	      load_or_abort("#{Rails.root}/db/schema.rb")
	    end
	    
	    #   Create a new config that is multi-tenanted
      # 
      #   @return {Hash} multi-tenanted database config
      #   @param {String} database Database name
      #   
      def multi_tenantify(database)
  			@config.clone.tap do |config|
  			  config[:database] = environmentify(database)
			  end
  		end
      
      #   Remove all non-alphanumeric characters
      # 
      #   @param {String} database Database name to sanitize
      # 
	    def sanitize(database)
	      warn("deprecated - Client should ensure proper database names are used")
	      database.gsub(/[\W]/,'')
      end
      
      #   Load a file or abort if it doesn't exist
      # 
      #   @param {String} file Full path of file to load
      # 
      def load_or_abort(file)
        if File.exists?(file)
          # Don't log the output of loading files (such as schema or seeds)
          silence_stream(STDOUT) do
            load(file)
          end
        else
          abort %{#{file} doesn't exist yet}
        end
      end
      
    end
  end
end
