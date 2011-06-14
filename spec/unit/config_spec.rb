require 'spec_helper'

describe Apartment do
  
  describe "#config" do
    
    let(:excluded_models){ [Company] }
    
    after do
      Apartment::Test.reset
    end
    
    it "should yield the Apartment object" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.should == Apartment
      end
    end
    
    it "should initialize Database" do
      Apartment::Database.should_receive(:init).once
      Apartment.configure
    end 
    
    it "should set excluded models" do
      Apartment.configure do |config|
        config.excluded_models = excluded_models
      end
      Apartment.excluded_models.should == excluded_models
    end
    
    it "should set postgres_schemas" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.use_postgres_schemas = false
      end
      Apartment.use_postgres_schemas.should be_false
    end
    
    context "databases" do
      it "should return object if it doesnt respond_to call" do
        database_names = ['users', 'companies']
        
        Apartment.configure do |config|
          config.excluded_models = []
          config.database_names = database_names
        end
        Apartment.database_names.should == database_names
      end
      
      it "should invoke the proc if appropriate" do
        database_names = lambda{ ['users', 'users'] }
        database_names.should_receive(:call)
        
        Apartment.configure do |config|
          config.excluded_models = []
          config.database_names = database_names
        end
        Apartment.database_names
      end
      
      it "should return the invoked proc if appropriate" do
        dbs = lambda{ Company.scoped }
        
        Apartment.configure do |config|
          config.excluded_models = []
          config.database_names = dbs
        end
        
        Apartment.database_names.should == Company.scoped
      end
        
    end
  end
end