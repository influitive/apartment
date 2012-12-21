require 'spec_helper'
require 'apartment/adapters/sqlserver_adapter'

describe Apartment::Adapters::SqlserverAdapter do
  unless defined?(JRUBY_VERSION)

    let(:config) { Apartment::Test.config['connections']['sqlserver'] }
    subject { Apartment::Database.sqlserver_adapter config.symbolize_keys }

    def database_names
      ActiveRecord::Base.connection.select_all("select name as database_name from sys.databases").collect { |row| row['database_name'] }
    end

    let(:default_database) { subject.process { ActiveRecord::Base.connection.current_database } }

    it_should_behave_like "a generic apartment adapter"
    it_should_behave_like "a db based apartment adapter"

  end
end