require 'spec_helper'
require 'apartment/elevators/domain'

describe Apartment::Elevators::Domain do

  subject(:elevator){ described_class.new(Proc.new{}) }

  describe "#parse_tenant_name" do
    it "parses the host for a domain name" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'example.com')
      elevator.parse_tenant_name(request).should == 'example'
    end

    it "ignores a www prefix and domain suffix" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'www.example.bc.ca')
      elevator.parse_tenant_name(request).should == 'example'
    end

    it "returns nil if there is no host" do
      request = ActionDispatch::Request.new('HTTP_HOST' => '')
      elevator.parse_tenant_name(request).should be_nil
    end
  end

  describe "#call" do
    it "switches to the proper tenant" do
      Apartment::Tenant.should_receive(:switch!).with('example')

      elevator.call('HTTP_HOST' => 'www.example.com')
    end
  end
end
