module Apartment

  module Adapters

    class AbstractJDBCAdapter < AbstractAdapter

      #   Drop the database
      #
      #   @param {String} database Database name
      #
      def drop(database)
        super(database)

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise DatabaseNotFound, "The database #{environmentify(database)} cannot be found"
      end

      protected

      #   Create the database
      #
      #   @param {String} database Database name
      #
      def create_database(database)
        super(database)

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise DatabaseExists, "The database #{environmentify(database)} already exists."
      end

      #   Connect to new database
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super(database)

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
