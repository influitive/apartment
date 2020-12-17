# frozen_string_literal: true

require 'spec_helper'
require 'apartment/elevators/generic'

describe Apartment::Elevators::Generic do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  class MyElevator < described_class
    def parse_tenant_name(*)
      'tenant2'
    end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  subject(:elevator) { described_class.new(proc {}) }

  describe '#call' do
    it 'calls the processor if given' do
      elevator = described_class.new(proc {}, proc { 'tenant1' })

      expect(Apartment::Tenant).to receive(:switch).with('tenant1')

      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it 'raises if parse_tenant_name not implemented' do
      expect do
        elevator.call('HTTP_HOST' => 'foo.bar.com')
      end.to raise_error(RuntimeError)
    end

    it 'switches to the parsed db_name' do
      elevator = MyElevator.new(proc {})

      expect(Apartment::Tenant).to receive(:switch).with('tenant2')

      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it 'calls the block implementation of `switch`' do
      elevator = MyElevator.new(proc {}, proc { 'tenant2' })

      expect(Apartment::Tenant).to receive(:switch).with('tenant2').and_yield
      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end

    it 'does not call `switch` if no database given' do
      app = proc {}
      elevator = MyElevator.new(app, proc {})

      expect(Apartment::Tenant).not_to receive(:switch)
      expect(app).to receive :call

      elevator.call('HTTP_HOST' => 'foo.bar.com')
    end
  end
end
