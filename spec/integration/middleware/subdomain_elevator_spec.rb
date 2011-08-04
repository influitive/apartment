require 'spec_helper'

describe Apartment::Elevators::Subdomain do
  
  let(:company){ mock_model(Company, :subdomain => 'foo').as_null_object }
  let(:domain){ "http://#{company.subdomain}.domain.com" }
  
  before do
    Apartment.seed_after_create = false
    Apartment.use_postgres_schemas = true
    
    Apartment::Database.create(company.subdomain)
  end
  
  after do
    Apartment::Test.drop_schema(company.subdomain)
  end
  
  context "single request" do
    it "should switch the db" do
      ActiveRecord::Base.connection.schema_search_path.should_not == 'foo'
      
      visit(domain)
      ActiveRecord::Base.connection.schema_search_path.should == company.subdomain
    end
  end
  
  context "simultaneous requests" do
    let(:company2){ mock_model(Company, :subdomain => 'bar').as_null_object }
    let(:domain2){ "http://#{company2.subdomain}.domain.com" }
    
    before do
      Apartment::Database.create(company2.subdomain)
      # Create some users for each db
      Apartment::Database.process(company.subdomain) do
        @c1_user_count = (2 + rand(2)).times{ User.create }
      end
      
      Apartment::Database.process(company2.subdomain) do
        @c2_user_count = (@c1_user_count + 2).times{ User.create }
      end
    end

    after do
      Apartment::Test.drop_schema(company2.subdomain)
    end
    
    it "should fetch the correct user count for each session based on subdomain" do
      visit(domain)
      
      in_new_session do |session|
        session.visit(domain2)
        User.count.should == @c2_user_count
      end
      
      visit(domain)
      User.count.should == @c1_user_count
    end
    
    
  end
  
end