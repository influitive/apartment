require 'spec_helper'
require 'apartment/adapters/mysql2_adapter'

describe Apartment::Adapters::Mysql2Adapter, database: :mysql do
  unless defined?(JRUBY_VERSION)

    subject(:adapter){ Apartment::Tenant.mysql2_adapter config }

    def tenant_names
      ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect { |row| row[0] }
    end

    let(:default_tenant) { subject.switch { ActiveRecord::Base.connection.current_database } }

    context "using - the equivalent of - schemas" do
      before { Apartment.use_schemas = true }

      it_should_behave_like "a generic apartment adapter"

      describe "#default_tenant" do
        it "is set to the original db from config" do
          expect(subject.default_tenant).to eq(config[:database])
        end
      end

      describe "#init" do
        include Apartment::Spec::AdapterRequirements

        before do
          Apartment.configure do |config|
            config.excluded_models = ["Company"]
          end
        end

        after do
          # Apartment::Tenant.init creates per model connection.
          # Remove the connection after testing not to unintentionally keep the connection across tests.
          Apartment.excluded_models.each do |excluded_model|
            excluded_model.constantize.remove_connection
          end
        end

        it "should process model exclusions" do
          Apartment::Tenant.init

          expect(Company.table_name).to eq("#{default_tenant}.companies")
        end
      end
    end

    context "using connections" do
      before { Apartment.use_schemas = false }

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a generic apartment adapter able to handle custom configuration"
      it_should_behave_like "a connection based apartment adapter"
    end
  end
end
