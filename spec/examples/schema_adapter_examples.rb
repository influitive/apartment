# frozen_string_literal: true

require 'spec_helper'
shared_examples_for 'a schema based apartment adapter' do
  include Apartment::Spec::AdapterRequirements

  let(:schema1) { db1 }
  let(:schema2) { db2 }
  let(:public_schema) { default_tenant }

  describe '#init' do
    before do
      Apartment.configure do |config|
        config.excluded_models = ['Company']
      end
    end

    after do
      # Apartment::Tenant.init creates per model connection.
      # Remove the connection after testing not to unintentionally keep the connection across tests.
      Apartment.excluded_models.each do |excluded_model|
        excluded_model.constantize.remove_connection
      end
    end

    it 'should process model exclusions' do
      Apartment::Tenant.init

      expect(Company.table_name).to eq('public.companies')
    end

    context 'with a default_tenant', default_tenant: true do
      it 'should set the proper table_name on excluded_models' do
        Apartment::Tenant.init

        expect(Company.table_name).to eq("#{default_tenant}.companies")
      end

      it 'sets the search_path correctly' do
        Apartment::Tenant.init

        expect(User.connection.schema_search_path).to match(/|#{default_tenant}|/)
      end
    end

    context 'persistent_schemas', persistent_schemas: true do
      it 'sets the persistent schemas in the schema_search_path' do
        Apartment::Tenant.init
        expect(connection.schema_search_path).to end_with persistent_schemas.map { |schema| %("#{schema}") }.join(', ')
      end
    end
  end

  #
  #   Creates happen already in our before_filter
  #
  describe '#create' do
    it 'should load schema.rb to new schema' do
      connection.schema_search_path = schema1
      expect(connection.tables).to include('companies')
    end

    it 'should yield to block if passed and reset' do
      subject.drop(schema2) # so we don't get errors on creation

      @count = 0 # set our variable so its visible in and outside of blocks

      subject.create(schema2) do
        @count = User.count
        expect(connection.schema_search_path).to start_with %("#{schema2}")
        User.create
      end

      expect(connection.schema_search_path).not_to start_with %("#{schema2}")

      subject.switch(schema2) { expect(User.count).to eq(@count + 1) }
    end

    context 'numeric database names' do
      let(:db) { 1234 }
      it 'should allow them' do
        expect do
          subject.create(db)
        end.to_not raise_error
        expect(tenant_names).to include(db.to_s)
      end

      after { subject.drop(db) }
    end
  end

  describe '#drop' do
    it 'should raise an error for unknown database' do
      expect do
        subject.drop 'unknown_database'
      end.to raise_error(Apartment::TenantNotFound)
    end

    context 'numeric database names' do
      let(:db) { 1234 }

      it 'should be able to drop them' do
        subject.create(db)
        expect do
          subject.drop(db)
        end.to_not raise_error
        expect(tenant_names).not_to include(db.to_s)
      end

      after do
        begin
          subject.drop(db)
        rescue StandardError => _e
          nil
        end
      end
    end
  end

  describe '#switch' do
    it 'connects and resets' do
      subject.switch(schema1) do
        expect(connection.schema_search_path).to start_with %("#{schema1}")
        expect(User.sequence_name).to eq "#{schema1}.#{User.table_name}_id_seq"
      end

      expect(connection.schema_search_path).to start_with %("#{public_schema}")
      expect(User.sequence_name).to eq "#{public_schema}.#{User.table_name}_id_seq"
    end

    it "allows a list of schemas" do
      subject.switch([schema1, schema2]) do
        expect(connection.schema_search_path).to include %{"#{schema1}"}
        expect(connection.schema_search_path).to include %{"#{schema2}"}
      end
    end
  end

  describe '#reset' do
    it 'should reset connection' do
      subject.switch!(schema1)
      subject.reset
      expect(connection.schema_search_path).to start_with %("#{public_schema}")
    end

    context 'with default_tenant', default_tenant: true do
      it 'should reset to the default schema' do
        subject.switch!(schema1)
        subject.reset
        expect(connection.schema_search_path).to start_with %("#{default_tenant}")
      end
    end

    context 'persistent_schemas', persistent_schemas: true do
      before do
        subject.switch!(schema1)
        subject.reset
      end

      it 'maintains the persistent schemas in the schema_search_path' do
        expect(connection.schema_search_path).to end_with persistent_schemas.map { |schema| %("#{schema}") }.join(', ')
      end

      context 'with default_tenant', default_tenant: true do
        it 'prioritizes the switched schema to front of schema_search_path' do
          subject.reset # need to re-call this as the default_tenant wasn't set at the time that the above reset ran
          expect(connection.schema_search_path).to start_with %("#{default_tenant}")
        end
      end
    end
  end

  describe '#switch!' do
    let(:tenant_presence_check) { true }

    before { Apartment.tenant_presence_check = tenant_presence_check }

    it 'should connect to new schema' do
      subject.switch!(schema1)
      expect(connection.schema_search_path).to start_with %("#{schema1}")
    end

    it 'should reset connection if database is nil' do
      subject.switch!
      expect(connection.schema_search_path).to eq(%("#{public_schema}"))
    end

    context 'when configuration checks for tenant presence before switching' do
      it 'should raise an error if schema is invalid' do
        expect do
          subject.switch! 'unknown_schema'
        end.to raise_error(Apartment::TenantNotFound)
      end
    end

    context 'when configuration skips tenant presence check before switching' do
      let(:tenant_presence_check) { false }

      it 'should not raise any errors' do
        expect do
          subject.switch! 'unknown_schema'
        end.to_not raise_error(Apartment::TenantNotFound)
      end
    end

    context 'numeric databases' do
      let(:db) { 1234 }

      it 'should connect to them' do
        subject.create(db)
        expect do
          subject.switch!(db)
        end.to_not raise_error

        expect(connection.schema_search_path).to start_with %("#{db}")
      end

      after { subject.drop(db) }
    end

    describe 'with default_tenant specified', default_tenant: true do
      before do
        subject.switch!(schema1)
      end

      it 'should switch out the default schema rather than public' do
        expect(connection.schema_search_path).not_to include default_tenant
      end

      it 'should still switch to the switched schema' do
        expect(connection.schema_search_path).to start_with %("#{schema1}")
      end
    end

    context 'persistent_schemas', persistent_schemas: true do
      before { subject.switch!(schema1) }

      it 'maintains the persistent schemas in the schema_search_path' do
        expect(connection.schema_search_path).to end_with persistent_schemas.map { |schema| %("#{schema}") }.join(', ')
      end

      it 'prioritizes the switched schema to front of schema_search_path' do
        expect(connection.schema_search_path).to start_with %("#{schema1}")
      end
    end
  end

  describe '#current' do
    it 'should return the current schema name' do
      subject.switch!(schema1)
      expect(subject.current).to eq(schema1)
    end

    context 'persistent_schemas', persistent_schemas: true do
      it 'should exlude persistent_schemas' do
        subject.switch!(schema1)
        expect(subject.current).to eq(schema1)
      end
    end
  end
end
