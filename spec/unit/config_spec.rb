# frozen_string_literal: true

require 'spec_helper'

describe Apartment do
  describe '#config' do
    let(:excluded_models) { ['Company'] }
    let(:seed_data_file_path) { Rails.root.join('db/seeds/import.rb') }

    def tenant_names_from_array(names)
      names.each_with_object({}) do |tenant, hash|
        hash[tenant] = Apartment.connection_config
      end.with_indifferent_access
    end

    it 'yields the Apartment object' do
      described_class.configure do |config|
        config.excluded_models = []
        expect(config).to eq(described_class)
      end
    end

    it 'sets excluded models' do
      described_class.configure do |config|
        config.excluded_models = excluded_models
      end
      expect(described_class.excluded_models).to eq(excluded_models)
    end

    it 'sets use_schemas' do
      described_class.configure do |config|
        config.excluded_models = []
        config.use_schemas = false
      end
      expect(described_class.use_schemas).to be false
    end

    it 'sets seed_data_file' do
      described_class.configure do |config|
        config.seed_data_file = seed_data_file_path
      end
      expect(described_class.seed_data_file).to eq(seed_data_file_path)
    end

    it 'sets seed_after_create' do
      described_class.configure do |config|
        config.excluded_models = []
        config.seed_after_create = true
      end
      expect(described_class.seed_after_create).to be true
    end

    it 'sets tenant_presence_check' do
      described_class.configure do |config|
        config.tenant_presence_check = true
      end
      expect(described_class.tenant_presence_check).to be true
    end

    it 'sets active_record_log' do
      described_class.configure do |config|
        config.active_record_log = true
      end
      expect(described_class.active_record_log).to be true
    end

    context 'when databases' do
      let(:users_conf_hash) { { port: 5444 } }

      before do
        described_class.configure do |config|
          config.tenant_names = tenant_names
        end
      end

      context 'when tenant_names as string array' do
        let(:tenant_names) { %w[users companies] }

        it 'returns object if it doesnt respond_to call' do
          expect(described_class.tenant_names).to eq(tenant_names_from_array(tenant_names).keys)
        end

        it 'sets tenants_with_config' do
          expect(described_class.tenants_with_config).to eq(tenant_names_from_array(tenant_names))
        end
      end

      context 'when tenant_names as proc returning an array' do
        let(:tenant_names) { -> { %w[users companies] } }

        it 'returns object if it doesnt respond_to call' do
          expect(described_class.tenant_names).to eq(tenant_names_from_array(tenant_names.call).keys)
        end

        it 'sets tenants_with_config' do
          expect(described_class.tenants_with_config).to eq(tenant_names_from_array(tenant_names.call))
        end
      end

      context 'when tenant_names as Hash' do
        let(:tenant_names) { { users: users_conf_hash }.with_indifferent_access }

        it 'returns object if it doesnt respond_to call' do
          expect(described_class.tenant_names).to eq(tenant_names.keys)
        end

        it 'sets tenants_with_config' do
          expect(described_class.tenants_with_config).to eq(tenant_names)
        end
      end

      context 'when tenant_names as proc returning a Hash' do
        let(:tenant_names) { -> { { users: users_conf_hash }.with_indifferent_access } }

        it 'returns object if it doesnt respond_to call' do
          expect(described_class.tenant_names).to eq(tenant_names.call.keys)
        end

        it 'sets tenants_with_config' do
          expect(described_class.tenants_with_config).to eq(tenant_names.call)
        end
      end
    end
  end
end
