require 'spec_helper'

describe Apartment::Elevators::Domain do

  let(:company){ mock_model(Company, :domain => 'foo').as_null_object }
  let(:domain){ "http://#{company.domain}.com" }
  let(:api){ Apartment::Database }

  before do
    Apartment.seed_after_create = false
    Apartment.use_postgres_schemas = true

    api.create(company.domain)
  end

  after{ api.drop(company.domain) }

  context "single request" do
    it "should switch the db" do
      ActiveRecord::Base.connection.schema_search_path.should_not == company.domain

      visit(domain)
      ActiveRecord::Base.connection.schema_search_path.should == company.domain
    end
  end

  context "simultaneous requests" do
    let(:company2){ mock_model(Company, :domain => 'bar').as_null_object }
    let(:domain2){ "http://#{company2.domain}.com" }

    before{ api.create(company2.domain) }
    after{ api.drop(company2.domain) }

    let!(:c1_user_count){ api.process(company.domain){ (2 + rand(2)).times{ User.create } } }
    let!(:c2_user_count){ api.process(company2.domain){ (c1_user_count + 2).times{ User.create } } }

    it "should fetch the correct user count for each session based on domain" do
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
