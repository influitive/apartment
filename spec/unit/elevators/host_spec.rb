require 'spec_helper'
require 'apartment/elevators/host'

describe Apartment::Elevators::Host do

  subject(:elevator){ described_class.new(Proc.new{}) }

  describe "#parse_tenant_name" do

    it "should return nil when no host" do
      request = ActionDispatch::Request.new('HTTP_HOST' => '')
      expect(elevator.parse_tenant_name(request)).to be_nil
    end

    context "assuming no ignored_first_subdomains" do
      before { allow(described_class).to receive(:ignored_first_subdomains).and_return([]) }

      context "with 3 parts" do
        it "should return the whole host" do
          request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.com')
          expect(elevator.parse_tenant_name(request)).to eq('foo.bar.com')
        end
      end

      context "with 6 parts" do
        it "should return the whole host" do
          request = ActionDispatch::Request.new('HTTP_HOST' => 'one.two.three.foo.bar.com')
          expect(elevator.parse_tenant_name(request)).to eq('one.two.three.foo.bar.com')
        end
      end
    end

    context "assuming ignored_first_subdomains is set" do
      before { allow(described_class).to receive(:ignored_first_subdomains).and_return(%w{www foo}) }

      context "with 3 parts" do
        it "should return host without www" do
          request = ActionDispatch::Request.new('HTTP_HOST' => 'www.bar.com')
          expect(elevator.parse_tenant_name(request)).to eq('bar.com')
        end

        it "should return host without foo" do
          request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.com')
          expect(elevator.parse_tenant_name(request)).to eq('bar.com')
        end
      end

      context "with 6 parts" do
        it "should return host without www" do
          request = ActionDispatch::Request.new('HTTP_HOST' => 'www.one.two.three.foo.bar.com')
          expect(elevator.parse_tenant_name(request)).to eq('one.two.three.foo.bar.com')
        end

        it "should return host without www" do
          request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.one.two.three.bar.com')
          expect(elevator.parse_tenant_name(request)).to eq('one.two.three.bar.com')
        end
      end
    end

    context "assuming localhost" do
      it "should return localhost" do
        request = ActionDispatch::Request.new('HTTP_HOST' => 'localhost')
        expect(elevator.parse_tenant_name(request)).to eq('localhost')
      end
    end

    context "assuming ip address" do
      it "should return the ip address" do
        request = ActionDispatch::Request.new('HTTP_HOST' => '127.0.0.1')
        expect(elevator.parse_tenant_name(request)).to eq('127.0.0.1')
      end
    end
  end

  describe "#call" do
    it "switches to the proper tenant" do
      allow(described_class).to receive(:ignored_first_subdomains).and_return([])
      expect(Apartment::Tenant).to receive(:switch).with('foo.bar.com')
      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it "ignores ignored_first_subdomains" do
      allow(described_class).to receive(:ignored_first_subdomains).and_return(%w{foo})
      expect(Apartment::Tenant).to receive(:switch).with('bar.com')
      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end
  end
end
