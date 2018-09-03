require 'spec_helper'

shared_examples_for "a generic apartment adapter" do
  include Apartment::Spec::AdapterRequirements

  before {
    Apartment.prepend_environment = false
    Apartment.append_environment = false
  }

  describe "#init" do
    it "should not retain a connection after railtie" do
      # this test should work on rails >= 4, the connection pool code is
      # completely different for 3.2 so we'd have to have a messy conditional..
      unless Rails::VERSION::MAJOR < 4
        ActiveRecord::Base.connection_pool.disconnect!

        Apartment::Railtie.config.to_prepare_blocks.map(&:call)

        num_available_connections = Apartment.connection_class.connection_pool
          .instance_variable_get(:@available)
          .instance_variable_get(:@queue)
          .size

        expect(num_available_connections).to eq(1)
      end
    end
  end

  #
  #   Creates happen already in our before_filter
  #
  describe "#create" do

    it "should create the new databases" do
      expect(tenant_names).to include(db1)
      expect(tenant_names).to include(db2)
    end

    it "should load schema.rb to new schema" do
      subject.switch(db1) do
        expect(connection.tables).to include('companies')
      end
    end

    it "should yield to block if passed and reset" do
      subject.drop(db2) # so we don't get errors on creation

      @count = 0  # set our variable so its visible in and outside of blocks

      subject.create(db2) do
        @count = User.count
        expect(subject.current).to eq(db2)
        User.create
      end

      expect(subject.current).not_to eq(db2)

      subject.switch(db2){ expect(User.count).to eq(@count + 1) }
    end

    it "should raise error when the schema.rb is missing unless Apartment.use_sql is set to true" do
      next if Apartment.use_sql

      subject.drop(db1)
      begin
        Dir.mktmpdir do |tmpdir|
          Apartment.database_schema_file = "#{tmpdir}/schema.rb"
          expect {
            subject.create(db1)
          }.to raise_error(Apartment::FileNotFound)
        end
      ensure
        Apartment.remove_instance_variable(:@database_schema_file)
      end
    end
  end

  describe "#drop" do
    it "should remove the db" do
      subject.drop db1
      expect(tenant_names).not_to include(db1)
    end
  end

  describe "#switch!" do
    it "should connect to new db" do
      subject.switch!(db1)
      expect(subject.current).to eq(db1)
    end

    it "should reset connection if database is nil" do
      subject.switch!
      expect(subject.current).to eq(default_tenant)
    end

    it "should raise an error if database is invalid" do
      expect {
        subject.switch! 'unknown_database'
      }.to raise_error(Apartment::ApartmentError)
    end
  end

  describe "#switch" do
    it "connects and resets the tenant" do
      subject.switch(db1) do
        expect(subject.current).to eq(db1)
      end
      expect(subject.current).to eq(default_tenant)
    end

    # We're often finding when using Apartment in tests, the `current` (ie the previously connect to db)
    # gets dropped, but switch will try to return to that db in a test.  We should just reset if it doesn't exist
    it "should not throw exception if current is no longer accessible" do
      subject.switch!(db2)

      expect {
        subject.switch(db1){ subject.drop(db2) }
      }.to_not raise_error
    end
  end

  describe "#reset" do
    it "should reset connection" do
      subject.switch!(db1)
      subject.reset
      expect(subject.current).to eq(default_tenant)
    end
  end

  describe "#current" do
    it "should return the current db name" do
      subject.switch!(db1)
      expect(subject.current).to eq(db1)
    end
  end

  describe "#each" do
    it "iterates over each tenant by default" do
      result = []
      Apartment.tenant_names = [db2, db1]

      subject.each do |tenant|
        result << tenant
        expect(subject.current).to eq(tenant)
      end

      expect(result).to eq([db2, db1])
    end

    it "iterates over the given tenants" do
      result = []
      Apartment.tenant_names = [db2]

      subject.each([db2]) do |tenant|
        result << tenant
        expect(subject.current).to eq(tenant)
      end

      expect(result).to eq([db2])
    end
  end
end
