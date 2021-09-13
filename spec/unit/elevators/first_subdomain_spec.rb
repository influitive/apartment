# frozen_string_literal: true

require 'spec_helper'
require 'apartment/elevators/first_subdomain'

describe Apartment::Elevators::FirstSubdomain do
  describe 'subdomain' do
    subject { described_class.new('test').parse_tenant_name(request) }

    let(:request) { double(:request, host: "#{subdomain}.example.com") }

    context 'when one subdomain' do
      let(:subdomain) { 'test' }

      it { is_expected.to eq('test') }
    end

    context 'when nested subdomains' do
      let(:subdomain) { 'test1.test2' }

      it { is_expected.to eq('test1') }
    end

    context 'when no subdomain' do
      let(:subdomain) { nil }

      it { is_expected.to eq(nil) }
    end
  end
end
