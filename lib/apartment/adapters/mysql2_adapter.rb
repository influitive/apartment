module Apartment

  module Database

    def self.mysql2_adapter(config)
      Apartment.use_schemas ?
        Adapters::Mysql2SchemaAdapter.new(config) :
        Adapters::Mysql2Adapter.new(config)
    end
  end

  module Adapters

    class Mysql2Adapter < AbstractAdapter

    protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {String} database Database name
      #
      def connect_to_new(database = nil)
        super
      rescue Mysql2::Error
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end
    end

    class Mysql2SchemaAdapter < AbstractAdapter
      attr_reader :default_database

      def initialize(config)
        @default_database = config[:database]

        super
      end

    protected

      #   Set schema search path to new schema
      #
      def connect_to_new(database)
        return reset if database.nil?

        Apartment.connection.execute "use #{database}"

      rescue ActiveRecord::StatementInvalid
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end
    end
  end
end
