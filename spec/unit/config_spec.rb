require 'spec_helper'

describe Apartment do

  describe "#config" do

    let(:excluded_models){ ["Company"] }
    let(:seed_data_file_path){ "#{Rails.root}/db/seeds/import.rb" }

    def tenant_names_from_array(names)
      names.each_with_object({}) do |tenant, hash|
        hash[tenant] = Apartment.connection_config
      end.with_indifferent_access
    end

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

    context "databases" do
      let(:users_conf_hash) { { port: 5444 } }

      before do
        Apartment.configure do |config|
          config.tenant_names = tenant_names
        end
      end

      context "tenant_names as string array" do
        let(:tenant_names) { ['users', 'companies'] }

        it "should return object if it doesnt respond_to call" do
          Apartment.tenant_names.should == tenant_names_from_array(tenant_names).keys
        end

        it "should set tenants_with_config" do
          Apartment.tenants_with_config.should == tenant_names_from_array(tenant_names)
        end
      end

      context "tenant_names as proc returning an array" do
        let(:tenant_names) { lambda { ['users', 'companies'] } }

        it "should return object if it doesnt respond_to call" do
          Apartment.tenant_names.should == tenant_names_from_array(tenant_names.call).keys
        end

        it "should set tenants_with_config" do
          Apartment.tenants_with_config.should == tenant_names_from_array(tenant_names.call)
        end
      end

      context "tenant_names as Hash" do
        let(:tenant_names) { { users: users_conf_hash }.with_indifferent_access }

        it "should return object if it doesnt respond_to call" do
          Apartment.tenant_names.should == tenant_names.keys
        end

        it "should set tenants_with_config" do
          Apartment.tenants_with_config.should == tenant_names
        end
      end

      context "tenant_names as proc returning a Hash" do
        let(:tenant_names) { lambda { { users: users_conf_hash }.with_indifferent_access } }

        it "should return object if it doesnt respond_to call" do
          Apartment.tenant_names.should == tenant_names.call.keys
        end

        it "should set tenants_with_config" do
          Apartment.tenants_with_config.should == tenant_names.call
        end
      end
    end

  end
end
