module Apartment

  module Adapters

    class AbstractJDBCAdapter < AbstractAdapter

      #   Get the current database name
      #
      #   @return {String} current database name
      #
      def current_database
        if @config[:driver] =~ /jtds/
          @current_database = Apartment.connection.database_name
        else
          @current_database = super
        end
      end
      alias_method :current, :current_database

      #   Drop the database
      #
      #   @param {String} database Database name
      #
      def drop(database)
        super(database)

      rescue DatabaseNotFound, ActiveRecord::JDBCError
        raise DatabaseNotFound, "The database #{environmentify(database)} cannot be found"
      end

      protected

      #   Create the database
      #
      #   @param {String} database Database name
      #
      def create_database(database)
        super(database)

      rescue DatabaseExists, ActiveRecord::JDBCError
        raise DatabaseExists, "The database #{environmentify(database)} already exists."
      end

      #   Connect to new database
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super(database)

      rescue DatabaseNotFound, ActiveRecord::JDBCError
        raise DatabaseNotFound, "The database #{environmentify(database)} cannot be found."
      end

      #   Return a new config that is multi-tenanted
      #
      def multi_tenantify(database)
        @config.clone.tap do |config|
          config[:url] = "#{config[:url].gsub(/(\S+)\/.+$/, '\1')}/#{environmentify(database)}"
        end
      end
    end
  end
end
