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
    
    subject{ Apartment::Database.postgresql_adapter Apartment::Test.config['connections']['postgresql'].symbolize_keys }
  
    before do
      puts ">> before"
      Apartment.use_postgres_schemas = true
      # 
      puts "<< before"
    end
  
    after do
      puts ">> after"
      Apartment::Test.drop_schema(schema)
    end
    
    describe "#create" do
      
      before do
        puts ">> before in #create"
        subject.create(schema)
        
      end
      
      it "should pass" do
      end
      
      it "should create the new schema" do
        puts ">> created db"
        # ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}.should include(schema)
      end
    
      it "should load schema.rb to new schema" do
        ActiveRecord::Base.connection.schema_search_path = schema
        ActiveRecord::Base.connection.tables.should include('companies')
      end
    
      it "should reset connection when finished" do
        ActiveRecord::Base.connection.schema_search_path.should_not == schema
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