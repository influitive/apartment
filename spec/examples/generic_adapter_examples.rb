require 'spec_helper'

shared_examples_for "a generic apartment adapter" do
  include Apartment::Spec::AdapterRequirements

  def dequote(string)
    string[0] == '"' && string[string.length - 1] == '"' ? string[1..-2] : string
  end

  #   I don't particularly like using Tenant#current for postgres tests,
  #   because it just return the instance var. This way we're looking at the
  #   actual schema search path of the connection. More peace of mind :)
  #
  def current_db
    case Apartment::Tenant.adapter.class.name
    when "Apartment::Adapters::PostgresqlAdapter"
      dequote(Apartment.connection.schema_search_path.split(",").first.strip)
    else
      Apartment::Tenant.current
    end
  end

  before {
    Apartment.prepend_environment = false
    Apartment.append_environment = false
  }

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
      subject.reset
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

    it "should be threadsafe" do
      unless Apartment::Tenant.adapter.class.name == "Apartment::Adapters::Sqlite3Adapter"
        lock = Mutex.new
        threads = []
        dbs = []
        pools = []
        # TODO: look in to 'too many connections' error.
        40.times do |n|
          threads << Thread.new do
            db = send("db#{(n % 2) + 1}")
            Apartment::Tenant.switch!(db)

            lock.synchronize do
              dbs   << [db, current_db]
              pools << ActiveRecord::Base.connection_pool.object_id
            end
          end
        end
        threads.each(&:join)

        expect(dbs.all?{ |expected, actual| expected == actual }).to be true
      end
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
