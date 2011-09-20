require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::PostgresqlAdapter do
  
  subject{ Apartment::Database.postgresql_adapter Apartment::Test.config['connections']['postgresql'].symbolize_keys }
  let(:config){ Apartment::Test.config['connections']['postgresql'] }
  
  context "using databases" do
    
    before do
      Apartment.use_postgres_schemas = false
    end
    
    let(:database_names){ ActiveRecord::Base.connection.execute("select datname from pg_database;").collect{|row| row['datname']} }
    
    it_should_behave_like "an apartment adapter"
    
  end
  
  context "using schemas" do
    
    let(:database_names){ ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']} }
    let(:schema1){ "schema1" }
    let(:schema2){ "schema2" }
    
    before do
      Apartment.use_postgres_schemas = true
      @default_schema = ActiveRecord::Base.connection.schema_search_path
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema1}")
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{schema2}")
    end
    
    after do
      ActiveRecord::Base.connection.execute("DROP SCHEMA #{schema1} CASCADE") rescue true # rescue in case we've already dropped
      ActiveRecord::Base.connection.execute("DROP SCHEMA #{schema2} CASCADE") rescue true
    end
    
    # it_should_behave_like "an apartment adapter"
    
    # Some extra tests pertaining to schemas
    
    describe "#create" do
      
      it "should create new postgres schema" do
        ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}.should include(database)
      end    
    end
    
    describe "#current_database" do
      
      it "should return the current schema name" do
        subject.switch(schema1)
        subject.current_database.should == schema1
      end
    end
    
    describe "#drop" do
      
      it "should delete the schema" do
        subject.drop schema1
        
        expect {
          subject.switch schema1
        }.to raise_error Apartment::SchemaNotFound
      end
      
      it "should raise error for unkown schema" do
        expect {
          subject.drop "unknown_schema"
        }.to raise_error Apartment::SchemaNotFound
      end
    end
    
    describe "#process" do
      
      it "should connect to new schema" do
        subject.process(schema1) do
          ActiveRecord::Base.connection.schema_search_path.should == schema1
        end
      end
      
      it "should reset if necessary" do
        subject.process(schema1)
        ActiveRecord::Base.connection.schema_search_path.should == @default_schema
      end
      
      it "should return to previous schema" do
        subject.switch(schema1)
        subject.process(schema2)
        ActiveRecord::Base.connection.schema_search_path.should == schema1
      end
    end
    
    describe "#reset" do
      
      it "should reset connection" do
        subject.switch(schema1)
        subject.reset
        ActiveRecord::Base.connection.schema_search_path.should == @default_schema
      end
    end
    
    describe "#switch" do
      
      it "should connect to new schema" do
        subject.switch(schema1)
        ActiveRecord::Base.connection.schema_search_path.should == schema1
      end
      
      it "should fail with invalid schema" do
        expect {
          Apartment::Database.switch('some_nonexistent_schema')
        }.to raise_error Apartment::SchemaNotFound
      end
      
      it "should reset connection if database is nil" do
        subject.switch
        ActiveRecord::Base.connection.schema_search_path.should == @default_schema
      end
    end
    
  end
  
end