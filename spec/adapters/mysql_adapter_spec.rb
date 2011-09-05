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
  
  context "using databases" do
    
    let(:database1){ 'first_database' }
    
    before do
      @mysql.create(database1)
    end
  
    after do
      ActiveRecord::Base.connection.drop_database(@mysql.environmentify(database1))
    end

    describe "#create" do
      it "should create the new database" do
        ActiveRecord::Base.connection.execute("SELECT schema_name FROM information_schema.schemata").collect{|row| row[0]}.should include(@mysql.environmentify(database1))
      end
    end

  end
  
  
end