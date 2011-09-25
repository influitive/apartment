require 'spec_helper'
require 'apartment/adapters/mysql2_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::Mysql2Adapter do
  
  subject{ Apartment::Database.mysql2_adapter Apartment::Test.config['connections']['mysql'].symbolize_keys }
  let(:config){ Apartment::Test.config['connections']['mysql'] }
  
  # Not sure why, but somehow using let(:database_names) memoizes for the whole example group, not just each test
  def database_names
    ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect{|row| row[0]} 
  end
  
  it_should_behave_like "an apartment adapter"

end