if defined?(JRUBY_VERSION)

  require 'spec_helper'
  require 'lib/apartment/adapters/jdbc_postgresql_adapter'

  describe Apartment::Adapters::JDBCPostgresqlAdapter, database: :postgresql do

    subject { Apartment::Tenant.jdbc_postgresql_adapter config.symbolize_keys }

    # Not sure why, but somehow using let(:tenant_names) memoizes for the whole example group, not just each test
    def tenant_names
      ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect { |row| row['nspname'] }
    end

    let(:default_tenant) { subject.switch { ActiveRecord::Base.connection.schema_search_path.gsub('"', '') } }

    it_should_behave_like "a generic apartment adapter"
    it_should_behave_like "a schema based apartment adapter"

  end
end
