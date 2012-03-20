module Apartment

  module Database

    def self.mysql2_adapter(config)
      Adapters::Mysql2Adapter.new config
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
      def connect_to_new(database)
        super
      rescue Mysql2::Error
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end
    end
  end
end
