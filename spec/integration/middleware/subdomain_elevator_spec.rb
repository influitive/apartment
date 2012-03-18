require 'spec_helper'

describe Apartment::Elevators::Subdomain do
  
  let(:company){ mock_model(Company, :subdomain => 'foo').as_null_object }
  let(:domain){ "http://#{company.subdomain}.domain.com" }
  let(:api){ Apartment::Database }
  
  before do
    Apartment.seed_after_create = false
    Apartment.use_postgres_schemas = true
    
    api.create(company.subdomain)
  end
  
  after{ api.drop(company.subdomain) }
  
  context "single request" do
    it "should switch the db" do
      ActiveRecord::Base.connection.schema_search_path.should_not == company.subdomain
      
      visit(domain)
      ActiveRecord::Base.connection.schema_search_path.should == company.subdomain
    end
  end
  
  context "simultaneous requests" do
    let(:company2){ mock_model(Company, :subdomain => 'bar').as_null_object }
    let(:domain2){ "http://#{company2.subdomain}.domain.com" }
    
    before{ api.create(company2.subdomain) }
    after{ api.drop(company2.subdomain) }
    
    let!(:c1_user_count){ api.process(company.subdomain){ (2 + rand(2)).times{ User.create } } }
    let!(:c2_user_count){ api.process(company2.subdomain){ (c1_user_count + 2).times{ User.create } } }
    
    it "should fetch the correct user count for each session based on subdomain" do
      visit(domain)
      
      in_new_session do |session|
        session.visit(domain2)
        User.count.should == c2_user_count
      end
      
      visit(domain)
      User.count.should == c1_user_count
    end
    
    
  end
  
end