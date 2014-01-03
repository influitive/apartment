require 'spec_helper'
require 'apartment/elevators/subdomain'

describe Apartment::Elevators::Subdomain do

  subject(:elevator){ described_class.new(Proc.new{}) }

  describe "#parse_database_name" do
    it "should parse subdomain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'foo.bar.com')
      elevator.parse_database_name(request).should == 'foo'
    end

    it "should return nil when no subdomain" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'bar.com')
      elevator.parse_database_name(request).should be_nil
    end
  end

  describe "#call" do
    it "switches to the correct tenant" do
      Apartment::Database.should_receive(:switch).with('foo')

      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it "ignores excluded subdomains" do
      described_class.excluded_subdomains = %w{foo}

      Apartment::Database.should_not_receive(:switch)

      elevator.call('HTTP_HOST' => 'foo.bar.com')

      described_class.excluded_subdomains = nil
    end
  end
end
