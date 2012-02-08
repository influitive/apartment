require 'spec_helper'

describe Apartment::Elevators::Subdomain do

  describe "#subdomain" do
    it "should parse subdomain" do
      elevator = Apartment::Elevators::Subdomain.new(nil)
      elevator.send(:subdomain, 'foo.bar.com').should == 'foo'
    end

    it "should return nil when no subdomain" do
      elevator = Apartment::Elevators::Subdomain.new(nil)
      elevator.send(:subdomain, 'bar.com').should be_nil
    end

    it "should only care about first subdomain" do
      elevator = Apartment::Elevators::Subdomain.new(nil)
      elevator.send(:subdomain, 'foo.baz.bar.com').should == 'foo'
    end

  end

end