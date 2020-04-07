# frozen_string_literal: true

if defined?(JRUBY_VERSION)

  require 'spec_helper'
  require 'apartment/adapters/jdbc_postgresql_adapter'

  describe Apartment::Adapters::JDBCPostgresqlAdapter, database: :postgresql do
    subject { Apartment::Tenant.jdbc_postgresql_adapter config.symbolize_keys }

    context 'using schemas' do
      before { Apartment.use_schemas = true }

      # Not sure why, but somehow using let(:tenant_names) memoizes for the whole example group, not just each test
      def tenant_names
        ActiveRecord::Base.connection.execute('SELECT nspname FROM pg_namespace;').collect { |row| row['nspname'] }
      end

      let(:default_tenant) { subject.switch { ActiveRecord::Base.connection.schema_search_path.gsub('"', '') } }

      it_should_behave_like 'a generic apartment adapter'
      it_should_behave_like 'a schema based apartment adapter'

      context 'using allow_prepend_tenant_name' do
        let(:api) { Apartment::Tenant }

        before do
          Apartment.allow_prepend_tenant_name = true
          api.create(db1)
          api.create(db2)
        end

        it 'prepends the tenant schema name to the table name when building the query' do
          Apartment::Tenant.switch!(db1)
          sql = "SELECT \"#{db1}\".\"users\".* FROM \"#{db1}\".\"users\" LIMIT 10"
          expect(UserWithTenantModel.all.limit(10).to_sql).to eq(sql)

          Apartment::Tenant.switch!(db2)
          sql = "SELECT \"#{db2}\".\"users\".* FROM \"#{db2}\".\"users\" LIMIT 10"
          expect(UserWithTenantModel.all.limit(10).to_sql).to eq(sql)
        end
      end
    end

    context 'using databases' do
      before { Apartment.use_schemas = false }

      # Not sure why, but somehow using let(:tenant_names) memoizes for the whole example group, not just each test
      def tenant_names
        connection.execute('select datname from pg_database;').collect { |row| row['datname'] }
      end

      let(:default_tenant) { subject.switch { ActiveRecord::Base.connection.current_database } }

      it_should_behave_like 'a generic apartment adapter'
      it_should_behave_like 'a connection based apartment adapter'
    end
  end
end
