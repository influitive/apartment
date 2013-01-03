require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'

describe Apartment::Adapters::PostgresqlAdapter do
  unless defined?(JRUBY_VERSION)
    let(:config){ Apartment::Test.config['connections']['postgresql'] }
    subject{ Apartment::Database.postgresql_adapter config.symbolize_keys }

    context "using schemas" do

      before{ Apartment.use_schemas = true }

      # Not sure why, but somehow using let(:database_names) memoizes for the whole example group, not just each test
      def database_names
        ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}
      end

      let(:default_database){ subject.process{ ActiveRecord::Base.connection.schema_search_path } }

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a schema based apartment adapter"
    end

    context "using databases" do

      before{ Apartment.use_schemas = false }

      # Not sure why, but somehow using let(:database_names) memoizes for the whole example group, not just each test
      def database_names
        connection.execute("select datname from pg_database;").collect{|row| row['datname']}
      end

      let(:default_database){ subject.process{ ActiveRecord::Base.connection.current_database } }

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a db based apartment adapter"
    end
  end
end