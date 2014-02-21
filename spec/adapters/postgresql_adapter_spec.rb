require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'

describe Apartment::Adapters::PostgresqlAdapter, database: :postgresql do
  unless defined?(JRUBY_VERSION)

    subject{ Apartment::Database.postgresql_adapter config }

    context "using schemas" do

      before{ Apartment.use_schemas = true }

      # Not sure why, but somehow using let(:tenant_names) memoizes for the whole example group, not just each test
      def tenant_names
        ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect { |row| row['nspname'] }
      end

      let(:default_tenant) { subject.process { ActiveRecord::Base.connection.schema_search_path.gsub('"', '') } }

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a schema based apartment adapter"
    end

    context "using connections" do

      before{ Apartment.use_schemas = false }

      # Not sure why, but somehow using let(:tenant_names) memoizes for the whole example group, not just each test
      def tenant_names
        connection.execute("select datname from pg_database;").collect { |row| row['datname'] }
      end

      let(:default_tenant) { subject.process { ActiveRecord::Base.connection.current_database } }

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a connection based apartment adapter"
    end
  end
end
