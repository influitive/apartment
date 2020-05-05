# frozen_string_literal: true

require 'spec_helper'

# NOTE: This is a dummy test because at the moment i cant think of a way to
# ensure that the callbacks are properly called. I'm open for ideas or I'll
# just delete this.
shared_examples_for 'a generic apartment adapter callbacks' do
  class MyProc
    def self.call; end
  end

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
        puts db1
        Apartment::Tenant.switch!(db1)
      end

      it 'runs both before and after callbacks' do
        expect(MyProc).to have_received(:call).twice
      end
    end
  end
end
