require 'spec_helper'

describe Apartment::Elevators::Subdomain do

  describe "#process" do
    it "should parse subdomain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.com')
      elevator = Apartment::Elevators::Subdomain.new(nil)
      elevator.process(request).should == 'foo'
    end

    it "should return nil when no subdomain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'bar.com')
      elevator = Apartment::Elevators::Subdomain.new(nil)
      elevator.process(request).should be_nil
    end

  end

end