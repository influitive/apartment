require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'

describe Apartment::Adapters::PostgresqlAdapter do

  let(:config){ Apartment::Test.config['connections']['postgresql'] }
  subject{ Apartment::Database.postgresql_adapter config.symbolize_keys }

  context "using schemas" do

    before{ Apartment.use_postgres_schemas = true }

    # Not sure why, but somehow using let(:database_names) memoizes for the whole example group, not just each test
    def database_names
      ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}
    end

    it_should_behave_like "a db based apartment adapter"
    it_should_behave_like "a schema based apartment adapter"
  end
  
  context "using databases" do

    before{ Apartment.use_postgres_schemas = false }  

    # Not sure why, but somehow using let(:database_names) memoizes for the whole example group, not just each test
    def database_names
      ActiveRecord::Base.connection.execute("select datname from pg_database;").collect{|row| row['datname']}
    end

    it_should_behave_like "a db based apartment adapter"
  end
end