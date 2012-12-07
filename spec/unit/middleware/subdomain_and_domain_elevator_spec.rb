require 'spec_helper'

describe Apartment::Elevators::SubdomainAndDomain do

  describe "#parse_database_name" do
    it "should parse subdomain and domain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.com')
      elevator = Apartment::Elevators::SubdomainAndDomain.new(nil)
      elevator.parse_database_name(request).should == 'foo_bar_com'
    end

    it "should return nil when no subdomain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'bar.com')
      elevator = Apartment::Elevators::SubdomainAndDomain.new(nil)
      elevator.parse_database_name(request).should be_nil
    end

  end

end