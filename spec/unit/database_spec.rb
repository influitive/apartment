require 'spec_helper'

describe Apartment::Database do
  
  describe "#init" do
    
    it "should process model exclusions" do      
      Company.connection.object_id.should == ActiveRecord::Base.connection.object_id
      
      # Configure calls init
      Apartment.configure do |config|
        config.excluded_models = [Company]
      end
      
      Company.connection.object_id.should_not == ActiveRecord::Base.connection.object_id
    end
    
  end
  
  describe "#process" do
    
    before do
      Apartment::Database.create database2
    end
    
    after do
      Apartment::Test.drop_schema database2
    end
    
    it "should connect to new schema" do
      Apartment::Database.process(database) do
        Apartment::Database.current_database.should == database
      end
    end

    it "should reset connection to the previous db" do
      Apartment::Database.switch(database2)
      Apartment::Database.process(database)
      Apartment::Database.current_database.should == database2
    end
    
    it "should reset to previous schema if database is nil" do
      Apartment::Database.switch(database)
      Apartment::Database.process
      Apartment::Database.current_database.should == database
    end
    
    it "should set to public schema if database is nil" do
      Apartment::Database.process do
        Apartment::Database.current_database.should == @default_schema
      end
    end
    
  end
  
  describe "#switch" do
    context "creating models" do
    
      before do
        Apartment::Database.create database2
      end

      after do
        Apartment::Test.drop_schema database2
      end
    
      it "should create a model instance in the current schema" do
        Apartment::Database.switch database2
        db2_count = User.count + x.times{ User.create }

        Apartment::Database.switch database
        db_count = User.count + x.times{ User.create }

        Apartment::Database.switch database2
        User.count.should == db2_count

        Apartment::Database.switch database
        User.count.should == db_count
      end
    end
  
    context "with excluded models" do
    
      Apartment.configure do |config|
        config.excluded_models = [Company]
      end
    
      it "should ignore excluded models" do
        Apartment::Database.switch database
        Company.connection.schema_search_path.should == @default_schema
      end
    
      it "should create excluded models in public schema" do
        Apartment::Database.reset # ensure we're on public schema
        count = Company.count + x.times{ Company.create }
      
        Apartment::Database.switch database
        x.times{ Company.create }
        Company.count.should == count + x
        Apartment::Database.reset
        Company.count.should == count + x
      end
    end
  end
  
  
end