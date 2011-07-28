require 'spec_helper'

describe Apartment::Database do
  
  context "using postgresql" do
    
    # See apartment.yml file in dummy app config
    
    let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
    let(:database){ "some_new_database" }
    
    before do
      ActiveRecord::Base.establish_connection config
      Apartment::Database.stub(:config).and_return config   # Use postgresql database config for this test
      @schema_search_path = ActiveRecord::Base.connection.schema_search_path
    end
    
    after do
      Apartment::Test.reset
    end
    
    describe "#init" do
      
      it "should process model exclusions" do
        Company.should_receive(:establish_connection).with( config )
        
        Apartment.configure do |config|
          config.excluded_models = [Company]
        end
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
        Apartment.configure do |config|
          config.excluded_models = []
          config.use_postgres_schemas = true
          config.seed_after_create = true
        end
        Apartment::Database.create database
      end
      
      after do
        Apartment::Test.drop_schema(database)
      end
      
      describe "#process" do
        it "should connect to new schema" do
          Apartment::Database.process(database) do
            ActiveRecord::Base.connection.schema_search_path.should == database
          end
        end

        it "should reset to public schema" do
          Apartment::Database.process(database)
          ActiveRecord::Base.connection.schema_search_path.should == @schema_search_path
        end
      end
      
      describe "#create" do
        it "should create new postgres schema" do
          ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}.should include(database)
        end
        
        it "should seed data" do
          Apartment::Database.switch database
          User.count.should be > 0
        end
      end
    
      describe "#switch" do
        
        let(:x){ rand(3) }
        
        it "should connect to new schema" do
          Apartment::Database.switch database
          ActiveRecord::Base.connection.schema_search_path.should == database
        end
        
        it "should fail with invalid schema" do
          expect {
            Apartment::Database.switch('some_nonexistent_schema')
          }.to raise_error Apartment::SchemaNotFound
        end
        
        context "creating models" do
          
          it "should create a normal model in the current schema" do
            count = User.count
            Apartment::Database.switch database
            new_count = User.count + x.times{ User.create }
            Apartment::Database.reset
            User.count.should == count
            Apartment::Database.switch database
            User.count.should == new_count
          end
        end
        
        context "with excluded models" do
          
          Apartment.configure do |config|
            config.excluded_models = [Company]
          end
          
          it "should ignore excluded models" do
            Apartment::Database.switch database
            Company.connection.schema_search_path.should == @schema_search_path
          end
          
          it "should create excluded models in public schema" do
            Apartment::Database.reset # ensure we're on public schema and get count
            count = Company.count
            
            Apartment::Database.switch database
            x.times{ Company.create }
            Company.count.should == count + x
            Apartment::Database.reset
            Company.count.should == count + x
          end
        end
        
      end
      
      describe "#current_database" do
        
        it "should return the current schema search path" do
          Apartment::Database.switch database
          Apartment::Database.current_database.should == database
        end
      end
      
    end
    
  end
end