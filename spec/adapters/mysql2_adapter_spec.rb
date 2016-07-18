require 'spec_helper'
require 'apartment/adapters/mysql2_adapter'

describe Apartment::Adapters::Mysql2Adapter, database: :mysql do
  unless defined?(JRUBY_VERSION)
    # patch for ActiveRecord 4.0 and MySQL 5.7 ...
    if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 0
      # force loading of the adapter ..
      require 'active_record/connection_adapters/abstract_mysql_adapter'
      module ActiveRecord
        module ConnectionAdapters
          class AbstractMysqlAdapter
            NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
          end
        end
      end
    end

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

        it "should process model exclusions" do
          Apartment::Tenant.init

          expect(Company.connection_pool).not_to eq(ActiveRecord::Base.connection_pool)
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
