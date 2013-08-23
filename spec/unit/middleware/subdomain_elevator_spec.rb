require 'spec_helper'
require 'apartment/elevators/subdomain'

describe Apartment::Elevators::Subdomain do

  describe "#parse_database_name" do
    it "should parse subdomain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.com')
      elevator = Apartment::Elevators::Subdomain.new(nil)
      elevator.parse_database_name(request).should == 'foo'
    end

    it "should return nil when no subdomain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'bar.com')
      elevator = Apartment::Elevators::Subdomain.new(nil)
      elevator.parse_database_name(request).should be_nil
    end
  end
end