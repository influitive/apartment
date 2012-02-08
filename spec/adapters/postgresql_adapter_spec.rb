require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::PostgresqlAdapter do

  before do
    ActiveRecord::Base.establish_connection Apartment::Test.config['connections']['postgresql']
    @schema_search_path = ActiveRecord::Base.connection.schema_search_path
  end

  after do
    ActiveRecord::Base.clear_all_connections!
  end

  context "using schemas" do

    let(:schema){ 'first_db_schema' }
    let(:schema2){ 'another_db_schema' }
    let(:database_names){ ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']} }

    subject{ Apartment::Database.postgresql_adapter Apartment::Test.config['connections']['postgresql'].symbolize_keys }

    before do
      Apartment.use_postgres_schemas = true
      subject.create(schema)
      subject.create(schema2)
    end

    after do
      # sometimes we manually drop these schemas in testing, dont' care if we can't drop hence rescue
      subject.drop(schema) rescue true
      subject.drop(schema2) rescue true
    end

    describe "#create" do

      it "should create the new schema" do
        database_names.should include(schema)
      end

      it "should load schema.rb to new schema" do
        ActiveRecord::Base.connection.schema_search_path = schema
        ActiveRecord::Base.connection.tables.should include('companies')
      end

      it "should not load schema.rb if load_schema is false" do
        Apartment.load_schema = false
        subject.create("schemax") do
          ActiveRecord::Base.connection.tables.should_not include('companies')
        end
        # Cleanup
        subject.drop("schemax")
      end

      it "should reset connection when finished" do
        ActiveRecord::Base.connection.schema_search_path.should_not == schema
      end

      it "should yield to block if passed" do
        Apartment::Test.migrate   # ensure we have latest schema in the public
        subject.drop(schema2) # so we don't get errors on creation

        @count = 0  # set our variable so its visible in and outside of blocks

        subject.create(schema2) do
          @count = User.count
          ActiveRecord::Base.connection.schema_search_path.should == schema2
          User.create
        end

        subject.process(schema2){ User.count.should == @count + 1 }
      end
    end

    describe "#drop" do

      it "should delete the database" do
        subject.switch schema    # can't drop db we're currently connected to, ensure these are different
        subject.drop schema2

        database_names.should_not include(schema2)
      end

      it "should raise an error for unkown database" do
        expect {
          subject.drop "unknown_database"
        }.to raise_error(Apartment::SchemaNotFound)
      end
    end


    describe "#process" do
      it "should connect" do
        subject.process(schema) do
          ActiveRecord::Base.connection.schema_search_path.should == schema
        end
      end

      it "should reset" do
        subject.process(schema)
        ActiveRecord::Base.connection.schema_search_path.should == @schema_search_path
      end

      # We're often finding when using Apartment in tests, the `current_database` (ie the previously attached to schema)
      # gets dropped, but process will try to return to that schema in a test.  We should just reset if it doesnt exist
      it "should not throw exception if current_database (schema) is no longer accessible" do
        subject.switch(schema2)

        expect {
          subject.process(schema){ subject.drop(schema2) }
        }.to_not raise_error(Apartment::SchemaNotFound)
      end
    end

    describe "#reset" do
      it "should reset connection" do
        subject.switch(schema)
        subject.reset
        ActiveRecord::Base.connection.schema_search_path.should == @schema_search_path
      end
    end

    describe "#switch" do
      it "should connect to new schema" do
        subject.switch(schema)
        ActiveRecord::Base.connection.schema_search_path.should == schema
      end

      it "should reset connection if database is nil" do
        subject.switch
        ActiveRecord::Base.connection.schema_search_path.should == @schema_search_path
      end
    end

    describe "#current_database" do
      it "should return the current schema name" do
        subject.switch(schema)
        subject.current_database.should == schema
      end
    end

  end

  context "using databases" do
    # TODO
  end
end