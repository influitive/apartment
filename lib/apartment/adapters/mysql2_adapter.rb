module Apartment

  module Database

    def self.mysql2_adapter(config)
      Apartment.use_schemas ?
        Adapters::Mysql2Adapter.new(config) :
        Adapters::Mysql2SchemaAdapter.new(config)
    end
  end

  module Adapters

    class Mysql2Adapter < AbstractAdapter

    protected
      #   Set schema search path to new schema
      #
      def connect_to_new(database = nil)
        return reset if database.nil?

        @current_database = database.to_s
        Apartment.connection.execute "use #{@current_database}"


      rescue ActiveRecord::StatementInvalid
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end

    end

    class Mysql2SchemaAdapter < AbstractAdapter

    protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database)
        super
      rescue Mysql2::Error
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end
    end
  end
end
