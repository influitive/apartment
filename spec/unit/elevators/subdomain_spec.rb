require 'spec_helper'
require 'apartment/elevators/subdomain'

describe Apartment::Elevators::Subdomain do

  subject(:elevator){ described_class.new(Proc.new{}) }

  describe "#parse_tenant_name" do
    context "assuming tld_length of 1" do
      it "should parse subdomain" do
        request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.com')
        elevator.parse_tenant_name(request).should == 'foo'
      end

      it "should return nil when no subdomain" do
        request = ActionDispatch::Request.new('HTTP_HOST' => 'bar.com')
        elevator.parse_tenant_name(request).should be_nil
      end
    end

    context "assuming tld_length of 2" do
      before do
        Apartment.configure do |config|
          config.tld_length = 2
        end
      end

      it "should parse subdomain in the third level domain" do
        request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.co.uk')
        elevator.parse_tenant_name(request).should == "foo"
      end

      it "should return nil when no subdomain in the third level domain" do
        request = ActionDispatch::Request.new('HTTP_HOST' => 'bar.co.uk')
        elevator.parse_tenant_name(request).should be_nil
      end
    end
  end

  describe "#call" do
    it "switches to the proper tenant" do
      Apartment::Tenant.should_receive(:switch!).with('tenant1')
      elevator.call('HTTP_HOST' => 'tenant1.example.com')
    end

    it "ignores excluded subdomains" do
      described_class.excluded_subdomains = %w{foo}

      Apartment::Tenant.should_not_receive(:switch!)

      elevator.call('HTTP_HOST' => 'foo.bar.com')

      described_class.excluded_subdomains = nil
    end
  end
end
