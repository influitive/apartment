require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::PostgresqlAdapter do
  
  before do
    ActiveRecord::Base.establish_connection Apartment::Test.config['connections']['postgresql']
    @pg = Apartment::Database.postgresql_adapter Apartment::Test.config['connections']['postgresql'].symbolize_keys
  end
  
  context "using schemas" do
  
    let(:schema1){ 'first_db_schema' }
    let(:schema_search_path){ ActiveRecord::Base.connection.schema_search_path }
    
    before do
      @pg.create(schema1)
    end
  
    after do
      Apartment::Test.drop_schema(schema1)
    end
  
    describe "#create" do
      it "should create the new schema" do
        ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}.should include(schema1)
      end
    
      it "should load schema.rb to new schema" do
        ActiveRecord::Base.connection.schema_search_path = schema1
        ActiveRecord::Base.connection.tables.should include('companies')
      end
    
      it "should reset connection when finished" do
        ActiveRecord::Base.connection.schema_search_path.should_not == schema1
      end
    end
    
    describe "#connect_and_reset" do
      it "should connect" do
        @pg.connect_and_reset(schema1) do
          ActiveRecord::Base.connection.schema_search_path.should == schema1
        end
      end
      
      it "should reset" do
        @pg.connect_and_reset(schema1)
        ActiveRecord::Base.connection.schema_search_path.should == schema_search_path
      end
    end
    
    describe "#reset" do
      it "should reset connection" do
        @pg.switch(schema1)
        @pg.reset
        ActiveRecord::Base.connection.schema_search_path.should == schema_search_path
      end
    end
    
    describe "#switch" do
      it "should connect to new schema" do
        @pg.switch(schema1)
        ActiveRecord::Base.connection.schema_search_path.should == schema1
      end
      
      it "should reset connection if database is nil" do
        @pg.switch
        ActiveRecord::Base.connection.schema_search_path.should == schema_search_path
      end
    end
    
  end
end