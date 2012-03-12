require 'spec_helper'

shared_examples_for "a schema based apartment adapter" do
  include Apartment::Spec::AdapterRequirements

  let(:schema1){ Apartment::Test.next_db }
  let(:schema2){ Apartment::Test.next_db }

  before do
    ActiveRecord::Base.establish_connection config
    subject.create(schema1)
    subject.create(schema2)
  end

  let!(:connection){ ActiveRecord::Base.connection }
  let!(:schema_search_path){ connection.schema_search_path }

  after do
    # sometimes we manually drop these schemas in testing, don't care if we can't drop hence rescue
    subject.drop(schema1) rescue true
    subject.drop(schema2) rescue true
    ActiveRecord::Base.clear_all_connections!
  end
  
  describe "#init" do
    
    it "should process model exclusions" do
      Apartment.configure do |config|
        config.excluded_models = ["Company"]
      end
      
      Apartment::Database.init
      
      Company.table_name.should == "public.companies"
    end
    
  end

  #
  #   Creates happen already in our before_filter
  #
  describe "#create" do

    it "should create the new schema" do
      database_names.should include(schema1)
    end

    it "should load schema.rb to new schema" do
      connection.schema_search_path = schema1
      connection.tables.should include('companies')
    end
    
    it "should yield to block if passed and reset" do
      subject.drop(schema2) # so we don't get errors on creation

      @count = 0  # set our variable so its visible in and outside of blocks

      subject.create(schema2) do
        @count = User.count
        connection.schema_search_path.should == schema2
        User.create
      end
      
      connection.schema_search_path.should_not == schema2

      subject.process(schema2){ User.count.should == @count + 1 }
    end
  end
  
  describe "#drop" do
    it "should raise an error for unkown database" do
      expect {
        subject.drop "unknown_database"
      }.to raise_error(Apartment::SchemaNotFound)
    end
  end

  describe "#process" do
    it "should connect" do
      subject.process(schema1) do
        connection.schema_search_path.should == schema1
      end
    end

    it "should reset" do
      subject.process(schema1)
      connection.schema_search_path.should == schema_search_path
    end

    # We're often finding when using Apartment in tests, the `current_database` (ie the previously attached to schema)
    # gets dropped, but process will try to return to that schema in a test.  We should just reset if it doesnt exist
    it "should not throw exception if current_database (schema) is no longer accessible" do
      subject.switch(schema2)

      expect {
        subject.process(schema1){ subject.drop(schema2) }
      }.to_not raise_error(Apartment::SchemaNotFound)
    end
  end

  describe "#reset" do
    it "should reset connection" do
      subject.switch(schema1)
      subject.reset
      connection.schema_search_path.should == schema_search_path
    end
  end

  describe "#switch" do
    it "should connect to new schema" do
      subject.switch(schema1)
      connection.schema_search_path.should == schema1
    end

    it "should reset connection if database is nil" do
      subject.switch
      connection.schema_search_path.should == schema_search_path
    end
  end

  describe "#current_database" do
    it "should return the current schema name" do
      subject.switch(schema1)
      subject.current_database.should == schema1
    end
  end

end