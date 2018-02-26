require 'spec_helper'
require 'apartment/migrator'

describe Apartment::Migrator do

  let(:tenant){ Apartment::Test.next_db }

  # Don't need a real switch here, just testing behaviour
  before { allow(Apartment::Tenant.adapter).to receive(:connect_to_new) }

  context "with ActiveRecord below 5.2.0", skip: ActiveRecord.version >= Gem::Version.new("5.2.0") do
    before do
      allow(ActiveRecord::Migrator).to receive(:migrations_paths) { %w(spec/dummy/db/migrate) }
      allow(Apartment::Migrator).to receive(:activerecord_below_5_2?) { true }
    end

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

  context "with ActiveRecord above or equal to 5.2.0", skip: ActiveRecord.version < Gem::Version.new("5.2.0") do
    before do
      allow(Apartment::Migrator).to receive(:activerecord_below_5_2?) { false }
    end

    describe "::migrate" do
      it "switches and migrates" do
        expect(Apartment::Tenant).to receive(:switch).with(tenant).and_call_original
        expect_any_instance_of(ActiveRecord::MigrationContext).to receive(:migrate)

        Apartment::Migrator.migrate(tenant)
      end
    end

    describe "::run" do
      it "switches and runs" do
        expect(Apartment::Tenant).to receive(:switch).with(tenant).and_call_original
        expect_any_instance_of(ActiveRecord::MigrationContext).to receive(:run).with(:up, 1234)

        Apartment::Migrator.run(:up, tenant, 1234)
      end
    end

    describe "::rollback" do
      it "switches and rolls back" do
        expect(Apartment::Tenant).to receive(:switch).with(tenant).and_call_original
        expect_any_instance_of(ActiveRecord::MigrationContext).to receive(:rollback).with(2)

        Apartment::Migrator.rollback(tenant, 2)
      end
    end
  end
end
