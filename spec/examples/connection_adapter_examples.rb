require 'spec_helper'

shared_examples_for "a connection based apartment adapter" do
  include Apartment::Spec::AdapterRequirements

  let(:default_tenant){ subject.switch{ ActiveRecord::Base.connection.current_database } }

  describe "#init" do
    it "should process model exclusions" do
      Apartment.configure do |config|
        config.excluded_models = ["Company"]
      end
      Apartment::Tenant.init

      Company.connection.object_id.should_not == ActiveRecord::Base.connection.object_id
    end
  end

  describe "#drop" do
    it "should raise an error for unknown database" do
      expect {
        subject.drop 'unknown_database'
      }.to raise_error(Apartment::TenantNotFound)
    end
  end

  describe "#switch!" do
    it "should raise an error if database is invalid" do
      expect {
        subject.switch! 'unknown_database'
      }.to raise_error(Apartment::TenantNotFound)
    end
  end
end
