require 'spec_helper'

describe Apartment::Migrator do
  
  let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
  let(:schema_name){ 'some_db_schema' }
  let(:version){ 1234 }
  
  before do
    ActiveRecord::Base.establish_connection config
    Apartment::Database.stub(:config).and_return config   # Use postgresql config for this test
    @original_schema = ActiveRecord::Base.connection.schema_search_path
  end
  
  context "postgresql" do

    context "using schemas" do
      
      describe "#migrate" do
        it "should connect to new db, then reset when done" do
          ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(schema_name).once
          ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@original_schema).once
          Apartment::Migrator.migrate(schema_name)
        end
  
        it "should migrate db" do
          ActiveRecord::Migrator.should_receive(:migrate)
          Apartment::Migrator.migrate(schema_name)
        end
      end
  
      describe "#run" do
        context "up" do
    
          it "should connect to new db, then reset when done" do
            ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(schema_name).once
            ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@original_schema).once
            Apartment::Migrator.run(:up, schema_name, version)
          end
  
          it "should migrate to a version" do
            ActiveRecord::Migrator.should_receive(:run).with(:up, anything, version)
            Apartment::Migrator.run(:up, schema_name, version)
          end
        end

        describe "down" do
    
          it "should connect to new db, then reset when done" do
            ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(schema_name).once
            ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@original_schema).once
            Apartment::Migrator.run(:down, schema_name, version)
          end

          it "should migrate to a version" do
            ActiveRecord::Migrator.should_receive(:run).with(:down, anything, version)
            Apartment::Migrator.run(:down, schema_name, version)
          end
        end
      end

      describe "#rollback" do
        let(:steps){ 3 }
  
        it "should rollback the db" do
          ActiveRecord::Migrator.should_receive(:rollback).with(anything, steps)
          Apartment::Migrator.rollback(schema_name, steps)
        end
      end
    end
  end
  
end