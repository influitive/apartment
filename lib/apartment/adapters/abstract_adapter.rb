require 'active_record'

module Apartment
  
  module Adapters
  
    class AbstractAdapter
      
      #   @constructor
      #   @param {Hash} config Database config
      #   @param {Hash} defaults Some default options
      # 
      def initialize(config, defaults = {})
        @config = config
        @defaults = defaults
      end
      
      #   Connect to db, do your biz, switch back to previous db
      # 
      #   @param {String?} database Database or schema to connect to
      def process(database = nil)
        current_db = current_database
		    switch(database)
		    yield if block_given?
		  ensure
  		  switch(current_db)
	    end
      
      #   Create new postgres schema
      # 
      #   @param {String} database Database name
  		def create(database)
        ActiveRecord::Base.connection.execute("CREATE DATABASE #{environmentify(sanitize(database))}")

  			process(database) do
    			import_database_schema

          # Seed data if appropriate
          seed_data if Apartment.seed_after_create
  			end
  		end
    
      #   Reset the base connection
      def reset
        ActiveRecord::Base.establish_connection @config
      end
      
      # Switch to new connection (or schema if appopriate)
      def switch(database = nil)
        # Just connect to default db and return
  			return reset if database.nil?

        connect_to_new(database)
  		end

      def environmentify(database)
        # prepend the environment if configured and the environment isn't already there
        return "#{Rails.env}_#{database}" if Apartment.prepend_environment && !database.include?(Rails.env)
        
        database
  		end
  		
  		def seed_data
	      load_or_abort("#{Rails.root}/db/seeds.rb")
      end
	    alias_method :seed, :seed_data
      
      # Return the current database name
      def current_database
        ActiveRecord::Base.connection.current_database
      end
      
    protected
    
      def connect_to_new(database)
        ActiveRecord::Base.establish_connection multi_tenantify(database)
		  end
      
	    def import_database_schema
	      load_or_abort("#{Rails.root}/db/schema.rb")
	    end
	    
	    # Return a new config that is multi-tenanted
      def multi_tenantify(database)
  			@config.clone.tap do |config|
  			  config[:database] = environmentify(database)
			  end
  		end
      
      # Remove all non-alphanumeric characters
	    def sanitize(database)
	      database.gsub(/[\W]/,'')
      end
      
      def load_or_abort(file)
        if File.exists?(file)
          load(file)
        else
          abort %{#{file} doesn't exist yet}
        end
      end
      
    end
  end
end
