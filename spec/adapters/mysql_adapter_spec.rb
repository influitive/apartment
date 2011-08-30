require 'spec_helper'
require 'apartment/adapters/mysql_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::MysqlAdapter do
  
  before do
    ActiveRecord::Base.establish_connection Apartment::Test.config['connections']['mysql']
    @mysql = Apartment::Database.mysql_adapter Apartment::Test.config['connections']['mysql'].symbolize_keys
  end
  
  after do
    ActiveRecord::Base.clear_all_connections!
  end
  
  describe "#create" do
    
    it "should create the new database" do
      pending
    end
  end
  
  
end