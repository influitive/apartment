require 'spec_helper'

describe Apartment::Database do
  
  let(:database1){ "apartment_database1" }
  let(:database2){ "apartment_database2" }
  
  before do
    Apartment.configure do |config|
      config.prepend_environment = false
      config.seed_after_create = true
      config.use_postgres_schemas = true
    end
    
    @default_schema = subject.current_database
    subject.create database1
    subject.create database2
  end
  
  after do
    # need to re-establish connection to default, because dropping a db that is currently connected to fails
    ActiveRecord::Base.establish_connection Rails.configuration.database_configuration[Rails.env].symbolize_keys
    subject.drop database1
    subject.drop database2
  end
  
  describe "#init" do
    
    it "should process model exclusions" do
      Apartment.configure do |config|
        config.excluded_models = [Company]
      end
      
      Company.table_name.should == "public.companies"
    end
    
  end
  
  describe "#process" do
    
    it "should connect to new schema" do
      subject.process(database1) do
        subject.current_database.should == database1
      end
    end

    it "should reset connection to the previous db" do
      subject.switch(database2)
      subject.process(database1)
      subject.current_database.should == database2
    end
    
    it "should reset to previous schema if database is nil" do
      subject.switch(database1)
      subject.process
      subject.current_database.should == database1
    end
    
    it "should set to public schema if database is nil" do
      subject.process do
        subject.current_database.should == @default_schema
      end
    end
    
  end
  
  describe "#switch" do
    
    let(:x){ rand(4) }
    
    context "creating models" do
    
      it "should create a model instance in the current schema" do
        subject.switch database2
        db2_count = User.count + x.times{ User.create }

        subject.switch database1
        db_count = User.count + x.times{ User.create }

        subject.switch database2
        User.count.should == db2_count

        subject.switch database1
        User.count.should == db_count
      end
      
    end
  
    context "with excluded models" do
    
      before do
        Apartment.configure do |config|
          config.excluded_models = [Company]
        end
      end
    
      it "should create excluded models in public schema" do
        subject.reset # ensure we're on public schema
        count = Company.count + x.times{ Company.create }
      
        subject.switch database1
        x.times{ Company.create }
        Company.count.should == count + x
        subject.reset
        Company.count.should == count + x
      end
    end
  end
  
  
end