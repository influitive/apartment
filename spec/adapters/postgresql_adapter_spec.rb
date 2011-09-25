require 'spec_helper'
require 'apartment/adapters/postgresql_adapter'   # specific adapters get dynamically loaded based on adapter name, so we must manually require here

describe Apartment::Adapters::PostgresqlAdapter do
  
  subject{ Apartment::Database.postgresql_adapter Apartment::Test.config['connections']['postgresql'].symbolize_keys }
  let(:config){ Apartment::Test.config['connections']['postgresql'] }
  
  context "using databases" do
    
    # Not sure why, but somehow using let(:database_names) memoizes for the whole example group, not just each test
    def database_names
      ActiveRecord::Base.connection.execute("select datname from pg_database;").collect{|row| row['datname']}
    end
    
    it_should_behave_like "an apartment adapter"
    
  end
  
  context "using schemas" do

    # Not sure why, but somehow using let(:database_names) memoizes for the whole example group, not just each test    
    def database_names
      ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}
    end
    
    it_should_behave_like "an apartment schema adapter"
    
  end
  
end