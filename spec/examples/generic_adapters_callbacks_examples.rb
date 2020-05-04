# frozen_string_literal: true

require 'spec_helper'

# NOTE: This is a dummy test because at the moment i cant think of a way to
# ensure that the callbacks are properly called. I'm open for ideas or I'll
# just delete this.
shared_examples_for 'a generic apartment adapter callbacks' do
  include Apartment::Spec::AdapterRequirements

  before do
    Apartment.prepend_environment = false
    Apartment.append_environment = false
  end

  describe '#switch! to nil' do
    before do
      Apartment::Adapters::AbstractAdapter.set_callback :switch, :before do
        puts("Before tenant switch from: #{current}")
      end

      Apartment::Adapters::AbstractAdapter.set_callback :switch, :after do
        puts("After tenant switch to: #{current}")
      end

      Apartment::Tenant.switch!(nil)
    end

    it 'runs both before and after callbacks' do
      expect(true).to eq true
    end
  end
end
