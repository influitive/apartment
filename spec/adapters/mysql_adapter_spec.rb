require 'spec_helper'
require 'apartment/adapters/mysql2_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::Mysql2Adapter do
  
  subject{ Apartment::Database.mysql2_adapter Apartment::Test.config['connections']['mysql'].symbolize_keys }
  let(:config){ Apartment::Test.config['connections']['mysql'] }
  let(:database_names){ ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect{|row| row[0]} }
  
  it_should_behave_like "an apartment adapter"

end