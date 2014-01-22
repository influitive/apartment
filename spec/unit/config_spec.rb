require 'spec_helper'

describe Apartment do

  describe "#config" do

    let(:excluded_models){ ["Company"] }

    it "should yield the Apartment object" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.should == Apartment
      end
    end

    it "should set excluded models" do
      Apartment.configure do |config|
        config.excluded_models = excluded_models
      end
      Apartment.excluded_models.should == excluded_models
    end

    it "should set use_schemas" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.use_schemas = false
      end
      Apartment.use_schemas.should be_false
    end

    it "should set schema_format" do
      Apartment.configure do |config|
        config.schema_format = :sql
      end
      Apartment.schema_format.should eq(:sql)
    end

    it "should set database_schema_file" do
      Apartment.configure do |config|
        config.database_schema_file = 'a_file'
      end
      Apartment.database_schema_file.should eq('a_file')
    end

    it "should set database_schema_file for :ruby schema format" do
      Apartment.configure do |config|
        config.schema_format = :ruby
      end
      Apartment.database_schema_file.to_s.should match(/schema.rb/)
    end

    it "should set database_schema_file for :sql schema format" do
      Apartment.configure do |config|
        config.schema_format = :sql
      end
      Apartment.database_schema_file.to_s.should match(/structure.sql/)
    end

    it "should set seed_after_create" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.seed_after_create = true
      end
      Apartment.seed_after_create.should be_true
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
        dbs = lambda{ Company.all }

        Apartment.configure do |config|
          config.excluded_models = []
          config.database_names = dbs
        end

        Apartment.database_names.should == Company.all
      end
    end

  end
end