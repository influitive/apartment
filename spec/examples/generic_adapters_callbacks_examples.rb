# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'a generic apartment adapter callbacks' do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  class MyProc
    def self.call(tenant_name); end
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  include Apartment::Spec::AdapterRequirements

  before do
    Apartment.prepend_environment = false
    Apartment.append_environment = false
  end

  describe '#switch!' do
    before do
      Apartment::Adapters::AbstractAdapter.set_callback :switch, :before do
        MyProc.call(Apartment::Tenant.current)
      end

      Apartment::Adapters::AbstractAdapter.set_callback :switch, :after do
        MyProc.call(Apartment::Tenant.current)
      end

      allow(MyProc).to receive(:call)
    end

    # NOTE: Part of the test setup creates and switches tenants, so we need
    # to reset the callbacks to ensure that each test run has the correct
    # counts
    after do
      Apartment::Adapters::AbstractAdapter.reset_callbacks :switch
    end

    context 'when tenant is nil' do
      before do
        Apartment::Tenant.switch!(nil)
      end

      it 'runs both before and after callbacks' do
        expect(MyProc).to have_received(:call).twice
      end
    end

    context 'when tenant is not nil' do
      before do
        Apartment::Tenant.switch!(db1)
      end

      it 'runs both before and after callbacks' do
        expect(MyProc).to have_received(:call).twice
      end
    end
  end
end
