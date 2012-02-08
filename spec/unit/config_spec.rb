require 'spec_helper'

describe Apartment do

  describe "#config" do

    let(:excluded_models){ [Company] }

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

    it "should set postgres_schemas" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.use_postgres_schemas = false
      end
      Apartment.use_postgres_schemas.should be_false
    end

    it "should set seed_after_create" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.seed_after_create = true
      end
      Apartment.seed_after_create.should be_true
    end

    context "load schema" do
      it "should default to true" do
        Apartment.configure
        Apartment.load_schema.should be_true
      end

      it "should set load_schema" do
        Apartment.configure do |config|
          config.load_schema = false
        end
        Apartment.load_schema.should be_false
      end
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

    describe "#reset" do

      before do
        Apartment.configure do |config|
          config.excluded_models = ["One", "Two"]
          config.database_names = ["one", "two"]
          config.seed_after_create = true
          config.load_schema = false
        end
      end

      it "should reset all the config options" do
        Apartment.reset
        Apartment.excluded_models.should == []
        Apartment.database_names.should be_nil
        Apartment.seed_after_create.should be_false
        Apartment.load_schema.should be_true
      end
    end

  end
end