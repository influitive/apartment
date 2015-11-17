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

  describe "#switch" do
    it "creates a new connection handler per thread" do
      hs = Mutex.new
      handlers = {}
      threads = []
      [1, 2].each do |i|
        threads << Thread.new do
          db_name = "db#{i}"
          Apartment::Tenant.switch(send(db_name)) do
            hs.synchronize{ handlers[db_name] = Apartment.connection_handler.object_id }
          end
        end
      end
      threads.each(&:join)

      expect(handlers["db1"]).not_to eq handlers["db2"]
    end
  end
end
