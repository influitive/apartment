require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'

describe Apartment::Adapters::PostgresqlAdapter do
  
  describe "#use_schemas?" do
    it "should use config option" do
      Apartment::Config.instance_variable_set :@config, :use_postgres_schemas => true
      adapter = Apartment::Adapters::PostgresqlAdapter.new
      adapter.use_schemas?.should be_true
    end
  end
  
end