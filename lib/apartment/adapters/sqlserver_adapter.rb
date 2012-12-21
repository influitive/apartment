module Apartment

  module Database

    def self.sqlserver_adapter(config)
      config['default_schema'] = 'dbo' if config['default_schema'].eql?('public')
      Adapters::SqlserverAdapter.new config
    end
  end

  module Adapters

    class SqlserverAdapter < AbstractAdapter

    protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super
      rescue TinyTds::Error
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end
    end
  end
end
