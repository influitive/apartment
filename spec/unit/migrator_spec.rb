require 'spec_helper'
require 'apartment/migrator'

describe Apartment::Migrator do

  let(:tenant){ Apartment::Test.next_db }

  # Don't need a real switch here, just testing behaviour
  before { Apartment::Tenant.adapter.stub(:connect_to_new) }

  describe "::migrate" do
    it "switches and migrates" do
      expect(Apartment::Tenant).to receive(:switch).with(tenant).and_call_original
      expect(ActiveRecord::Migrator).to receive(:migrate)

      Apartment::Migrator.migrate(tenant)
    end
  end

  describe "::run" do
    it "switches and runs" do
      expect(Apartment::Tenant).to receive(:switch).with(tenant).and_call_original
      expect(ActiveRecord::Migrator).to receive(:run).with(:up, anything, 1234)

      Apartment::Migrator.run(:up, tenant, 1234)
    end
  end

  describe "::rollback" do
    it "switches and rolls back" do
      expect(Apartment::Tenant).to receive(:switch).with(tenant).and_call_original
      expect(ActiveRecord::Migrator).to receive(:rollback).with(anything, 2)

      Apartment::Migrator.rollback(tenant, 2)
    end
  end
end
