require 'spec_helper'
require 'apartment/elevators/generic'

describe Apartment::Elevators::Generic do

  class MyElevator < described_class
    def parse_tenant_name(*)
      'tenant2'
    end
  end

  subject(:elevator){ described_class.new(Proc.new{}) }

  describe "#call" do
    it "calls the processor if given" do
      elevator = described_class.new(Proc.new{}, Proc.new{'tenant1'})

      expect(Apartment::Tenant).to receive(:switch).with('tenant1')

      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it "raises if parse_tenant_name not implemented" do
      expect {
        elevator.call('HTTP_HOST' => 'foo.bar.com')
      }.to raise_error(RuntimeError)
    end

    it "switches to the parsed db_name" do
      elevator = MyElevator.new(Proc.new{})

      expect(Apartment::Tenant).to receive(:switch).with('tenant2')

      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it "calls the block implementation of `switch`" do
      elevator = MyElevator.new(Proc.new{}, Proc.new{'tenant2'})

      expect(Apartment::Tenant).to receive(:switch).with('tenant2').and_yield
      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it "does not call `switch` if no database given" do
      app = Proc.new{}
      elevator = MyElevator.new(app, Proc.new{})

      expect(Apartment::Tenant).not_to receive(:switch)
      expect(app).to receive :call

      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end
  end
end
