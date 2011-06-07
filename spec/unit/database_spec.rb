require 'spec_helper'

describe Apartment::Database do
  
  let(:config){ {'adapter' => 'postgresql', 'database' => 'some_database'} }
  let(:schema_name){ 'some_database_schema' }
  let(:multi_tenant_config){ config.merge 'schema_search_path' => schema_name }
  let(:version){ 1234 }
  
  before do
    Apartment::Database.stub(:config).and_return config
    Apartment::Database.stub(:import_database_schema)
    ActiveRecord::Base.stub(:connection).and_return stub('Connection')
  end
  
  describe "#switch" do
    
    it "should establish original connection with no database" do
      ActiveRecord::Base.should_receive(:establish_connection).with config
      Apartment::Database.switch
    end
    
    context "using postgres schemas" do
      
      before do
        Apartment::Database.stub(:use_schemas?).and_return true
      end
      
      context "with no model exclusions" do
        
        before do
          Apartment::Config.stub(:excluded_models).and_return []
        end
              
        it "should establish new connection to passed in database" do
          ActiveRecord::Base.should_receive(:establish_connection).with multi_tenant_config
          Apartment::Database.switch(schema_name)
        end
      end
      
      context "with exclusions" do
        before do
          Apartment::Config.stub(:excluded_models).and_return ['Admin::Company', 'User']
        end
        
        it "should connect excluded model with original config" do
          Admin::Company.should_receive(:establish_connection).with config
          User.should_receive(:establish_connection).with config
          Apartment::Database.switch(schema_name)
        end
        
        it "should raise an error for unkown class names" do
          Apartment::Config.stub(:excluded_models).and_return ['Admin::Company', 'User', "Unknown::Class"]
          lambda{
            Apartment::Database.switch(schema_name)
          }.should raise_error
        end
          
      end
      
    end
    
  end
  
  describe "#create" do
    
    before do
      ActiveRecord::Base.connection.stub :initialize_schema_migrations_table  # stub out migration table init
    end
    
    context "with postgres schemas" do
      
      before do
        Apartment::Database.stub(:use_schemas?).and_return true
      end
      
      it "should create the new schema" do
        ActiveRecord::Base.connection.should_receive(:execute).with("create schema #{schema_name}")
        Apartment::Database.create(schema_name)
      end
      
      # need more tests
      
    end
    
    context "without postgres schemas" do
      
      before do
        Apartment::Database.stub(:use_schemas?).and_return false
      end
      
      it "should not create schema" do
        ActiveRecord::Base.connection.should_not_receive(:execute)
        Apartment::Database.create(schema_name)
      end
    end
  end
  
  context "migrations" do
    before do
      ActiveRecord::Base.stub(:establish_connection)
    end
    
    describe "#migrate" do
      it "should connect to new db, then reset when done" do
        ActiveRecord::Migrator.stub(:migrate)
        ActiveRecord::Base.should_receive(:establish_connection).with(multi_tenant_config).once
        ActiveRecord::Base.should_receive(:establish_connection).with(config).once
        Apartment::Database.migrate(schema_name)
      end
    
      it "should migrate db" do
        ActiveRecord::Migrator.should_receive(:migrate)
        Apartment::Database.migrate(schema_name)
      end
    end
  
    describe "#migrate_up" do
      
      it "should connect to new db, then reset when done" do
        ActiveRecord::Migrator.stub(:run)
        ActiveRecord::Base.should_receive(:establish_connection).with(multi_tenant_config).once
        ActiveRecord::Base.should_receive(:establish_connection).with(config).once
        Apartment::Database.migrate_up(schema_name, version)
      end
    
      it "should migrate to a version" do
        ActiveRecord::Migrator.should_receive(:run).with(:up, anything, version)
        Apartment::Database.migrate_up(schema_name, version)
      end
    end
  
    describe "#migrate_down" do
      
      it "should connect to new db, then reset when done" do
        ActiveRecord::Migrator.stub(:run)
        ActiveRecord::Base.should_receive(:establish_connection).with(multi_tenant_config).once
        ActiveRecord::Base.should_receive(:establish_connection).with(config).once
        Apartment::Database.migrate_down(schema_name, version)
      end

      it "should migrate to a version" do
        ActiveRecord::Migrator.should_receive(:run).with(:down, anything, version)
        Apartment::Database.migrate_down(schema_name, version)
      end
    end
  end
  
  describe "#rollback" do
    before do
      ActiveRecord::Base.stub :establish_connection
    end
    
    let(:steps){ 3 }
    
    it "should rollback the db" do
      ActiveRecord::Migrator.should_receive(:rollback).with(anything, steps)
      Apartment::Database.rollback(schema_name, steps)
    end
  end
  
end