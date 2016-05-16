require 'spec_helper'
require 'apartment/elevators/domain'

describe Apartment::Elevators::Domain do

  subject(:elevator){ described_class.new(Proc.new{}) }

  describe "#parse_tenant_name" do
    it "parses the host for a domain name" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'example.com')
      expect(elevator.parse_tenant_name(request)).to eq('example')
    end

    it "ignores a www prefix and domain suffix" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'www.example.bc.ca')
      expect(elevator.parse_tenant_name(request)).to eq('example')
    end

    it "returns nil if there is no host" do
      request = ActionDispatch::Request.new('HTTP_HOST' => '')
      expect(elevator.parse_tenant_name(request)).to be_nil
    end
  end

  describe "#call" do
    it "switches to the proper tenant" do
      expect(Apartment::Tenant).to receive(:switch).with('example')

      elevator.call('HTTP_HOST' => 'www.example.com')
    end
  end
end
