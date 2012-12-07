module Apartment

  module Adapters

    class AbstractJDBCAdapter < AbstractAdapter

      #   Drop the database
      #
      #   @param {String} database Database name
      #
      def drop(database)
        Apartment.connection.execute("DROP DATABASE #{environmentify(database)}")

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise DatabaseNotFound, "The database #{environmentify(database)} cannot be found"
      end

      protected

      #   Create the database
      #
      #   @param {String} database Database name
      #
      def create_database(database)
        Apartment.connection.create_database(environmentify(database))

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise DatabaseExists, "The database #{environmentify(database)} already exists."
      end

      #   Connect to new database
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        Apartment.establish_connection multi_tenantify(database)
        Apartment.connection.active? # call active? to manually check if this connection is valid

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
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
