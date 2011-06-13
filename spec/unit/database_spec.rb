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
  
  describe "#create_schema" do
    let(:schema_name){ "some_schema" }
    
    it "should succeed" do
      ActiveRecord::Base.connection.should_receive(:execute).with("CREATE SCHEMA #{schema_name}")
      Apartment::Database.create_schema(schema_name)
    end
    
    it "should sanitize name" do
      bad_name = "some'nam\"e"
      ActiveRecord::Base.connection.should_receive(:execute).with("CREATE SCHEMA somename")
      Apartment::Database.create_schema(bad_name)
    end
    
    it "should ensure it is on the public schema before creating the new schema" do
      pending("cant stub out any longer here... we need to start integration testing")
      Apartment::Database.init
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