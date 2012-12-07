module Apartment

  module Database

    def self.mysql2_adapter(config)
      Adapters::Mysql2Adapter.new config
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
  end
end
