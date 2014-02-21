require 'spec_helper'

shared_examples_for "a generic apartment adapter" do
  include Apartment::Spec::AdapterRequirements

  before {
    Apartment.prepend_environment = false
    Apartment.append_environment = false
  }

  #
  #   Creates happen already in our before_filter
  #
  describe "#create" do

    it "should create the new databases" do
      tenant_names.should include(db1)
      tenant_names.should include(db2)
    end

    it "should load schema.rb to new schema" do
      subject.process(db1) do
        connection.tables.should include('companies')
      end
    end

    it "should yield to block if passed and reset" do
      subject.drop(db2) # so we don't get errors on creation

      @count = 0  # set our variable so its visible in and outside of blocks

      subject.create(db2) do
        @count = User.count
        subject.current_tenant.should == db2
        User.create
      end

      subject.current_tenant.should_not == db2

      subject.process(db2){ User.count.should == @count + 1 }
    end
  end

  describe "#drop" do
    it "should remove the db" do
      subject.drop db1
      tenant_names.should_not include(db1)
    end
  end

  describe "#process" do
    it "should connect" do
      subject.process(db1) do
        subject.current_tenant.should == db1
      end
    end

    it "should reset" do
      subject.process(db1)
      subject.current_tenant.should == default_tenant
    end

    # We're often finding when using Apartment in tests, the `current_tenant` (ie the previously connect to db)
    # gets dropped, but process will try to return to that db in a test.  We should just reset if it doesn't exist
    it "should not throw exception if current_tenant is no longer accessible" do
      subject.switch(db2)

      expect {
        subject.process(db1){ subject.drop(db2) }
      }.to_not raise_error
    end
  end

  describe "#reset" do
    it "should reset connection" do
      subject.switch(db1)
      subject.reset
      subject.current_tenant.should == default_tenant
    end
  end

  describe "#switch" do
    it "should connect to new db" do
      subject.switch(db1)
      subject.current_tenant.should == db1
    end

    it "should reset connection if database is nil" do
      subject.switch
      subject.current_tenant.should == default_tenant
    end

    it "should raise an error if database is invalid" do
      expect {
        subject.switch 'unknown_database'
      }.to raise_error(Apartment::ApartmentError)
    end
  end

  describe "#current_tenant" do
    it "should return the current db name" do
      subject.switch(db1)
      subject.current_tenant.should == db1
      subject.current.should == db1
    end
  end
end
