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

      #   Create a new database, import schema, seed if appropriate
      #
      #   @param {String} database Database name
      #
      def create(database)
        create_database(database)

        process(database) do
          import_database_schema(database)

          # Seed data if appropriate
          seed_data if Apartment.seed_after_create

          yield if block_given?
        end
      end

      #   Get the current database name
      #
      #   @return {String} current database name
      #
      def current_database
        ActiveRecord::Base.connection.current_database
      end
      alias_method :current, :current_database

      #   Drop the database
      #
      #   @param {String} database Database name
      #
      def drop(database)
        # ActiveRecord::Base.connection.drop_database   note that drop_database will not throw an exception, so manually execute
        ActiveRecord::Base.connection.execute("DROP DATABASE #{environmentify(database)}" )

      rescue ActiveRecord::StatementInvalid
        raise DatabaseNotFound, "The database #{environmentify(database)} cannot be found"
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
        switch(current_db) rescue reset
      end

      #   Establish a new connection for each specific excluded model
      #
      def process_excluded_models
        # All other models will shared a connection (at ActiveRecord::Base) and we can modify at will
        Apartment.excluded_models.each do |excluded_model|
          # Note that due to rails reloading, we now take string references to classes rather than
          # actual object references.  This way when we contantize, we always get the proper class reference
          if excluded_model.is_a? Class
            warn "[Deprecation Warning] Passing class references to excluded models is now deprecated, please use a string instead"
            excluded_model = excluded_model.name
          end

          excluded_model.constantize.establish_connection @config
        end
      end

      #   Reset the database connection to the default
      #
      def reset
        ActiveRecord::Base.establish_connection @config
      end

      #   Switch to new connection (or schema if appopriate)
      #
      #   @param {String} database Database name
      #
      def switch(database = nil)
        # Just connect to default db and return
        return reset if database.nil?

        connect_to_new(database)
      end

      #   Load the rails seed file into the db
      #
      def seed_data
        silence_stream(STDOUT){ load_or_abort("#{Rails.root}/db/seeds.rb") } # Don't log the output of seeding the db
      end
      alias_method :seed, :seed_data

    protected

      #   Create the database
      #
      #   @param {String} database Database name
      #
      def create_database(database)
        ActiveRecord::Base.connection.create_database( environmentify(database) )

      rescue ActiveRecord::StatementInvalid
        raise DatabaseExists, "The database #{environmentify(database)} already exists."
      end

      #   Connect to new database
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        ActiveRecord::Base.establish_connection multi_tenantify(database)
        ActiveRecord::Base.connection.active?   # call active? to manually check if this connection is valid

      rescue ActiveRecord::StatementInvalid
        raise DatabaseNotFound, "The database #{environmentify(database)} cannot be found."
      end

      #   Prepend the environment if configured and the environment isn't already there
      #
      #   @param {String} database Database name
      #   @return {String} database name with Rails environment *optionally* prepended
      #
      def environmentify(database)
        unless database.include?(Rails.env)
          if Apartment.prepend_environment
            "#{Rails.env}_#{database}"
          elsif Apartment.append_environment
            "#{database}_#{Rails.env}"
          end
        else
          database
        end
      end

      #   Import the database schema
      #
      def import_database_schema(database = nil)
        ActiveRecord::Schema.verbose = false    # do not log schema load output.
        if Rails.application.config.active_record.schema_format == :sql
          execute_or_abort("#{Rails.root}/db/structure.sql", database)
        else
          load_or_abort("#{Rails.root}/db/schema.rb")
        end
      end

      #   Return a new config that is multi-tenanted
      #
      def multi_tenantify(database)
        @config.clone.tap do |config|
          config[:database] = environmentify(database)
        end
      end

      #   Load a file or abort if it doesn't exists
      #
      def load_or_abort(file)
        if File.exists?(file)
          load(file)
        else
          abort %{#{file} doesn't exist yet}
        end
      end

      #   Load a SQL file and execute it or abort if it doesn't exists
      #
      def execute_or_abort(file, database)
        if File.exists?(file)
          structure_sql = open(file, 'r').read
          # structure_sql.gsub! /public/, database
          ActiveRecord::Base.connection.execute(structure_sql)
        else
          abort %{#{file} doesn't exist yet}
        end
      end

    end
  end
end
