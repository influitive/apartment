require 'spec_helper'
require 'apartment/adapters/mysql2_adapter'

describe Apartment::Adapters::Mysql2Adapter, database: :mysql do
  unless defined?(JRUBY_VERSION)

    subject(:adapter){ Apartment::Database.mysql2_adapter config }

    def tenant_names
      ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect { |row| row[0] }
    end

    let(:default_tenant) { subject.process { ActiveRecord::Base.connection.current_database } }

    context "using - the equivalent of - schemas" do
      before { Apartment.use_schemas = true }

      it_should_behave_like "a generic apartment adapter"

      describe "#default_tenant" do
        its(:default_tenant){ should == config[:database] }
      end

      describe "#init" do
        include Apartment::Spec::AdapterRequirements

        before do
          Apartment.configure do |config|
            config.excluded_models = ["Company"]
          end
        end

        it "should process model exclusions" do
          Apartment::Database.init

          Company.table_name.should == "#{default_tenant}.companies"
        end
      end
    end

    context "using connections" do
      before { Apartment.use_schemas = false }

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a connection based apartment adapter"
    end
  end
end
