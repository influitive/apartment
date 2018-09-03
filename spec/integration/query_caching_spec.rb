require 'spec_helper'

describe 'query caching' do
  describe 'when use_schemas = true' do
    let(:db_names) { [db1, db2] }

    before do
      Apartment.configure do |config|
        config.excluded_models = ["Company"]
        config.tenant_names = lambda{ Company.pluck(:database) }
        config.use_schemas = true
      end

      Apartment::Tenant.reload!(config)

      db_names.each do |db_name|
        Apartment::Tenant.create(db_name)
        Company.create database: db_name
      end
    end

    after do
      db_names.each{ |db| Apartment::Tenant.drop(db) }
      Apartment::Tenant.reset
      Company.delete_all
    end

    it 'clears the ActiveRecord::QueryCache after switching databases' do
      db_names.each do |db_name|
        Apartment::Tenant.switch! db_name
        User.create! name: db_name
      end

      ActiveRecord::Base.connection.enable_query_cache!

      Apartment::Tenant.switch! db_names.first
      expect(User.find_by_name(db_names.first).name).to eq(db_names.first)

      Apartment::Tenant.switch! db_names.last
      expect(User.find_by_name(db_names.first)).to be_nil
    end
  end

  describe 'when use_schemas = false' do
    let(:db_name) { db1 }

    before do
      Apartment.configure do |config|
        config.excluded_models = ["Company"]
        config.tenant_names = lambda{ Company.pluck(:database) }
        config.use_schemas = false
      end

      Apartment::Tenant.reload!(config)

      Apartment::Tenant.create(db_name)
      Company.create database: db_name
    end

    after do
      # Avoid cannot drop the currently open database. Maybe there is a better way to handle this.
      Apartment::Tenant.switch! 'template1'

      Apartment::Tenant.drop(db_name)
      Apartment::Tenant.reset
      Company.delete_all
    end

    it "configuration value is kept after switching databases" do
      ActiveRecord::Base.connection.enable_query_cache!

      Apartment::Tenant.switch! db_name
      expect(Apartment.connection.query_cache_enabled).to be true

      ActiveRecord::Base.connection.disable_query_cache!

      Apartment::Tenant.switch! db_name
      expect(Apartment.connection.query_cache_enabled).to be false
    end
  end
end
