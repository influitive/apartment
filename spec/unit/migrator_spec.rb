require 'spec_helper'

describe Apartment::Migrator do

  let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
  let(:schema_name){ Apartment::Test.next_db }
  let(:version){ 20110613152810 }     # note this is brittle!  I've literally just taken the version of the one migration I made...  don't change this version

  before do
    ActiveRecord::Base.establish_connection config
    Apartment::Database.stub(:config).and_return config   # Use postgresql config for this test
    @original_schema = ActiveRecord::Base.connection.schema_search_path

    Apartment.configure do |config|
      config.use_schemas = true
      config.excluded_models = []
      config.database_names = [schema_name]
    end

    Apartment::Database.create schema_name    # create the schema
    migrations_path = Rails.root + ActiveRecord::Migrator.migrations_path     # tell AR where the real migrations are
    ActiveRecord::Migrator.stub(:migrations_path).and_return(migrations_path)
  end

  after do
    Apartment::Test.drop_schema(schema_name)
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