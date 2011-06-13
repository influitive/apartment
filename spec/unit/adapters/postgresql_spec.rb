require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::PostgresqlAdapter do
  
  before do
    ActiveRecord::Base.establish_connection Apartment::Test.config['connections']['postgresql']
  end
  
  describe "#using_schemas?" do
    it "should use config option" do
      Apartment::Config.instance_variable_set :@config, :use_postgres_schemas => true
      adapter = Apartment::Adapters::PostgresqlAdapter.new
      adapter.using_schemas?.should be_true
    end
  end
  
end