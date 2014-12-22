if defined?(JRUBY_VERSION)

  require 'spec_helper'
  require 'lib/apartment/adapters/jdbc_mysql_adapter'

  describe Apartment::Adapters::JDBCMysqlAdapter, database: :mysql do

    subject { Apartment::Tenant.jdbc_mysql_adapter config.symbolize_keys }

    def tenant_names
      ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect { |row| row['schema_name'] }
    end

    let(:default_tenant) { subject.switch { ActiveRecord::Base.connection.current_database } }

    it_should_behave_like "a generic apartment adapter"
    it_should_behave_like "a connection based apartment adapter"
  end
end
