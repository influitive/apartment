require 'spec_helper'

describe Apartment::Elevators::Subdomain, :elevator => true do

  let(:domain1)   { "http://#{database1}.example.com" }
  let(:domain2)   { "http://#{database2}.example.com" }

  it_should_behave_like "an apartment elevator"

  context "With Subdomain Excluded" do
    let(:domain_with_excluded_subdomain) { "http://www.example.com" }

    before do
      Apartment::Elevators::Subdomain.excluded_subdomains = %w(www)
      # FIXME:
      # This is used because the dummy app includes all three middlewares. The domain middleware specifically
      # tries to lookup the example schema and tries to switch to it. I don't know how to go around this.
      Apartment::Database.create("example")
    end

    it_should_behave_like "an apartment elevator"

    it "shouldnt switch the schema if the subdomain is excluded" do
      ActiveRecord::Base.connection.schema_search_path.should_not == "www"
      visit(domain_with_excluded_subdomain)
      ActiveRecord::Base.connection.schema_search_path.should_not == "www"
    end

    after do
      Apartment::Elevators::Subdomain.excluded_subdomains = []
      Apartment::Database.drop("example")
    end
  end
end