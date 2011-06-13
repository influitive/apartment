require 'spec_helper'

describe Apartment::Database do
  
  context "using postgresql" do
    
    # See apartment.yml file in dummy app config
    
    let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
    let(:database){ "some_new_database" }
    
    before do
      ActiveRecord::Base.establish_connection config
      @schema_search_path = ActiveRecord::Base.connection.schema_search_path
      Apartment::Database.stub(:config).and_return config   # Use postgresql config for this test
    end
    
    describe "#init" do
      it "should process model exclusions" do
        Company.should_receive(:establish_connection).with( config )
        Apartment::Database.init
      end
      
      it "should raise an error for unkown class names" do
        Apartment::Config.stub(:excluded_models).and_return ['Company', 'User', "Unknown::Class"]
        
        expect{
          Apartment::Database.init
        }.to raise_error
      end
      
    end
    
    describe "#adapter" do
      before do
        Apartment::Database.reload!
      end
      
      it "should load postgresql adapter" do
        Apartment::Database.adapter
        Apartment::Adapters::PostgresqlAdapter.should be_a(Class)
        
      end
      
      it "should raise exception with invalid adapter specified" do
        Apartment::Database.stub(:config).and_return config.merge(:adapter => 'unkown')
        
        expect {
          Apartment::Database.adapter
        }.to raise_error
      end
      
    end
    
    context "with schemas" do
      
      before do
        Apartment::Database.create database
      end
      
      after do
        ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{database} CASCADE")
      end
      
      describe "#create" do
        it "should create new postgres schema" do
          ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}.should include(database)
        end
      end
    
      describe "#switch" do
        it "should connect to new schema" do
          Apartment::Database.switch database
          ActiveRecord::Base.connection.schema_search_path.should == database
        end
        
        it "should ignore excluded models" do
          Apartment::Database.switch database
          Company.connection.schema_search_path.should == @schema_search_path
        end
        
        it "should fail with invalid schema" do
          expect {
            Apartment::Database.switch('some_nonexistent_schema')
          }.to raise_error Apartment::SchemaNotFound
        end
      end
    end
    
  end
end