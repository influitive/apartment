require 'spec_helper'

describe Apartment do

  describe "#config" do

    let(:excluded_models){ ["Company"] }
    let(:seed_data_file_path){ "#{Rails.root}/db/seeds/import.rb" }

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
      Apartment.use_schemas.should be false
    end

    it "should set seed_data_file" do
      Apartment.configure do |config|
        config.seed_data_file = seed_data_file_path
      end
      Apartment.seed_data_file.should eq(seed_data_file_path)
    end

    it "should set seed_after_create" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.seed_after_create = true
      end
      Apartment.seed_after_create.should be true
    end

    it "should set tld_length" do
      Apartment.configure do |config|
        config.tld_length = 2
      end
      Apartment.tld_length.should == 2
    end

    context "databases" do
      it "should return object if it doesnt respond_to call" do
        tenant_names = ['users', 'companies']

        Apartment.configure do |config|
          config.excluded_models = []
          config.tenant_names = tenant_names
        end
        Apartment.tenant_names.should == tenant_names
      end

      it "should invoke the proc if appropriate" do
        tenant_names = lambda{ ['users', 'users'] }
        tenant_names.should_receive(:call)

        Apartment.configure do |config|
          config.excluded_models = []
          config.tenant_names = tenant_names
        end
        Apartment.tenant_names
      end

      it "should return the invoked proc if appropriate" do
        dbs = lambda{ Company.all }

        Apartment.configure do |config|
          config.excluded_models = []
          config.tenant_names = dbs
        end

        Apartment.tenant_names.should == Company.all
      end
    end

  end
end
