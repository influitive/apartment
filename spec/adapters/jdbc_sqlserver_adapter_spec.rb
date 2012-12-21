if defined?(JRUBY_VERSION)

  require 'spec_helper'
  require 'lib/apartment/adapters/jdbc_sqlserver_adapter'

  describe Apartment::Adapters::JDBCSqlserverAdapter do


    let(:config) { Apartment::Test.config['connections']['sqlserver'] }
    subject { Apartment::Database.jdbc_sqlserver_adapter config.symbolize_keys }

    def database_names
      ActiveRecord::Base.connection.execute("select name as database_name from sys.databases").collect { |row| row['database_name'] }
    end

    let(:default_database) { subject.process { ActiveRecord::Base.connection.database_name } }

    it_should_behave_like "a generic apartment adapter"
    it_should_behave_like "a db based apartment adapter"

  end

end