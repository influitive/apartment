module Apartment

  module Database
    def self.jdbc_sqlserver_adapter(config)
      config['default_schema'] = 'dbo' if config['default_schema'].eql?('public')
      Adapters::JDBCSqlserverAdapter.new config
    end
  end

  module Adapters
    class JDBCSqlserverAdapter < AbstractJDBCAdapter

      protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super(database)
      rescue DatabaseNotFound
        self.reset
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end
    end
  end
end
