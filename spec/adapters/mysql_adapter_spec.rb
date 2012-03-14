require 'spec_helper'
require 'apartment/adapters/mysql_adapter'

describe Apartment::Adapters::MysqlAdapter do
  
  let(:config){ Apartment::Test.config['connections']['mysql'] }
  subject{ Apartment::Database.mysql2_adapter config.symbolize_keys }
  
  def database_names
    ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect{|row| row[0]}
  end
  
  let(:default_database){ subject.process{ ActiveRecord::Base.connection.current_database } }
  
  it_should_behave_like "a generic apartment adapter"
  it_should_behave_like "a db based apartment adapter"
end