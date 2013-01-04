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

      #   Reset current_database to the default_database
      #
      def reset
        connect_to_new(default_database)
      end

      #   Set the table_name to always use the default database for excluded models
      #
      def process_excluded_models
        Apartment.excluded_models.each{ |model| process_excluded_model(model) }
      end

    protected

      #   Set schema current_database to new db
      #
      def connect_to_new(database)
        return reset if database.nil?

        Apartment.connection.execute "use #{database}"

      rescue ActiveRecord::StatementInvalid
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find database #{environmentify(database)}"
      end

      def process_excluded_model(model)
        model.constantize.tap do |klass|
          # some models (such as delayed_job) seem to load and cache their column names before this,
          # so would never get the default prefix, so reset first
          klass.reset_column_information

          # Ensure that if a schema *was* set, we override
          table_name = klass.table_name.split('.', 2).last

          # Not sure why, but Delayed::Job somehow ignores table_name_prefix...  so we'll just manually set table name instead
          klass.table_name = "#{default_database}.#{table_name}"
        end
      end
    end
  end
end
