require 'apartment/adapters/abstract_adapter'

module Apartment
  module Database
    def self.sqlite3_adapter(config)
      Adapters::Sqlite3Adapter.new(config)
    end
  end

  module Adapters
    class Sqlite3Adapter < AbstractAdapter
      def initialize(config)
        @default_dir = File.expand_path(File.dirname(config[:database]))

        super
      end

      def drop(database)
        raise DatabaseNotFound,
          "The database #{environmentify(database)} cannot be found." unless File.exists?(database_file(database))

        File.delete(database_file(database))
      end

      def current_database
        File.basename(Apartment.connection.instance_variable_get(:@config)[:database], '.sqlite3')
      end

      protected

      def connect_to_new(database)
        raise DatabaseNotFound,
          "The database #{environmentify(database)} cannot be found." unless File.exists?(database_file(database))

        super database_file(database)
      end

      def create_database(database)
        raise DatabaseExists,
          "The database #{environmentify(database)} already exists." if File.exists?(database_file(database))

        f = File.new(database_file(database), File::CREAT)
        f.close
      end

      private

      def database_file(database)
        "#{@default_dir}/#{database}.sqlite3"
      end
    end
  end
end
