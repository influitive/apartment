if defined?(JRUBY_VERSION)

  require 'spec_helper'
  require 'lib/apartment/adapters/jdbc_mysql_adapter'

  describe Apartment::Adapters::JDBCMysqlAdapter do


    let(:config) { Apartment::Test.config['connections']['mysql'] }
    subject { Apartment::Database.jdbc_mysql_adapter config.symbolize_keys }

    def database_names
      ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect { |row| row['schema_name'] }
    end

    let(:default_database) { subject.process { ActiveRecord::Base.connection.current_database } }

    it_should_behave_like "a generic apartment adapter"
    it_should_behave_like "a db based apartment adapter"

  end

end
