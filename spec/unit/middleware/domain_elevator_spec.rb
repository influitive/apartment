require 'spec_helper'

describe Apartment::Elevators::Domain do

  describe "#domain" do
    it "parses the host for a domain name" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'example.com')
      elevator = Apartment::Elevators::Domain.new(nil)
      elevator.domain(request).should == 'example'
    end

    it "ignores a www prefix and domain suffix" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'www.example.bc.ca')
      elevator = Apartment::Elevators::Domain.new(nil)
      elevator.domain(request).should == 'example'
    end

    it "returns nil if there is no host" do
      request = ActionDispatch::Request.new('HTTP_HOST' => '')
      elevator = Apartment::Elevators::Domain.new(nil)
      elevator.domain(request).should be_nil
    end

  end

end
