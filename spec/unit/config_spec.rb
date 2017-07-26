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
        expect(config).to eq(Apartment)
      end
    end

    it "should set excluded models" do
      Apartment.configure do |config|
        config.excluded_models = excluded_models
      end
      expect(Apartment.excluded_models).to eq(excluded_models)
    end

    it "should set use_schemas" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.use_schemas = false
      end
      expect(Apartment.use_schemas).to be false
    end

    it "should set seed_data_file" do
      Apartment.configure do |config|
        config.seed_data_file = seed_data_file_path
      end
      expect(Apartment.seed_data_file).to eq(seed_data_file_path)
    end

    it "should set seed_after_create" do
      Apartment.configure do |config|
        config.excluded_models = []
        config.seed_after_create = true
      end
      expect(Apartment.seed_after_create).to be true
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
          expect(Apartment.tenant_names).to eq(tenant_names_from_array(tenant_names).keys)
        end

        it "should set tenants_with_config" do
          expect(Apartment.tenants_with_config).to eq(tenant_names_from_array(tenant_names))
        end
      end

      context "tenant_names as proc returning an array" do
        let(:tenant_names) { lambda { ['users', 'companies'] } }

        it "should return object if it doesnt respond_to call" do
          expect(Apartment.tenant_names).to eq(tenant_names_from_array(tenant_names.call).keys)
        end

        it "should set tenants_with_config" do
          expect(Apartment.tenants_with_config).to eq(tenant_names_from_array(tenant_names.call))
        end
      end

      context "tenant_names as Hash" do
        let(:tenant_names) { { users: users_conf_hash }.with_indifferent_access }

        it "should return object if it doesnt respond_to call" do
          expect(Apartment.tenant_names).to eq(tenant_names.keys)
        end

        it "should set tenants_with_config" do
          expect(Apartment.tenants_with_config).to eq(tenant_names)
        end
      end

      context "tenant_names as proc returning a Hash" do
        let(:tenant_names) { lambda { { users: users_conf_hash }.with_indifferent_access } }

        it "should return object if it doesnt respond_to call" do
          expect(Apartment.tenant_names).to eq(tenant_names.call.keys)
        end

        it "should set tenants_with_config" do
          expect(Apartment.tenants_with_config).to eq(tenant_names.call)
        end
      end
    end

  end
end
