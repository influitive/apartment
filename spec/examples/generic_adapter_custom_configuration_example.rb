require 'spec_helper'

shared_examples_for "a generic apartment adapter able to handle custom configuration" do

  let(:custom_tenant_name) { 'test_tenantwwww' }
  let(:db) { |example| example.metadata[:database]}
  let(:custom_tenant_names) do
    {
      custom_tenant_name => get_custom_db_conf
    }
  end

  before do
    Apartment.tenant_names = custom_tenant_names
    Apartment.with_multi_server_setup = true
  end

  after do
    Apartment.with_multi_server_setup = false
  end

  context "database key taken from specific config" do

    let(:expected_args) { get_custom_db_conf }

    describe "#create" do
      it "should establish_connection with the separate connection with expected args" do
        expect(Apartment::Adapters::AbstractAdapter::SeparateDbConnectionHandler).to receive(:establish_connection).with(expected_args).and_call_original

        # because we dont have another server to connect to it errors
        # what matters is establish_connection receives proper args
        expect { subject.create(custom_tenant_name) }.to raise_error(Apartment::TenantExists)
      end
    end

    describe "#drop" do
      it "should establish_connection with the separate connection with expected args" do
        expect(Apartment::Adapters::AbstractAdapter::SeparateDbConnectionHandler).to receive(:establish_connection).with(expected_args).and_call_original

        # because we dont have another server to connect to it errors
        # what matters is establish_connection receives proper args
        expect { subject.drop(custom_tenant_name) }.to raise_error(Apartment::TenantNotFound)
      end
    end
  end

  context "database key from tenant name" do

    let(:expected_args) {
      get_custom_db_conf.tap {|args| args.delete(:database) }
    }

    describe "#switch!" do

      it "should connect to new db" do
        expect(Apartment).to receive(:establish_connection) do |args|
          db_name = args.delete(:database)

          expect(args).to eq expected_args
          expect(db_name).to match custom_tenant_name

          # we only need to check args, then we short circuit
          # in order to avoid the mess due to the `establish_connection` override
          raise ActiveRecord::ActiveRecordError
        end

        expect { subject.switch!(custom_tenant_name) }.to raise_error(Apartment::TenantNotFound)
      end
    end
  end

  def specific_connection
    {
      postgresql: {
        adapter:  'postgresql',
        database: 'override_database',
        password: 'override_password',
        username: 'overridepostgres'
      },
      mysql: {
        adapter:  'mysql2',
        database: 'override_database',
        username: 'root'
      },
      sqlite: {
        adapter:  'sqlite3',
        database: 'override_database'
      }
    }
  end

  def get_custom_db_conf
    specific_connection[db.to_sym].with_indifferent_access
  end
end
