# The following should be used in all adapter tests to ensure they conform to the proper Apartment::Database spec
# Note I'm not crazy about this implementation, it uses methods from the system under test to actually test itself
# Couldn't think of a better way to share functionality ??

shared_examples_for "an apartment adapter" do
  
  let(:database1){ "apartment_database1" }
  let(:database2){ "apartment_database2" }
  
  before(:all) do
    Apartment::Database.config = config
    ActiveRecord::Base.establish_connection config
  end
  
  after(:all) do
    # This is lame, I had to remove cached classes and this triggers a code reload so that each example_Group
    # regenerates its table_name quoting, otherwise switching adapters fails with invalid sql
    ActiveRecord::Base.descendants.each{ |klass| klass.reset_table_name; klass.reset_column_information }
  end
    
  before do
    Apartment.use_postgres_schemas = false
    Apartment.prepend_environment = false   # disabled env prepending for most tests
    Apartment.seed_after_create = true      # to test seeding
    
    subject.create(database1)
    subject.create(database2)
  end

  after do
    # need to re-establish connection to default, because dropping a db that is currently connected to fails
    ActiveRecord::Base.establish_connection config
    subject.drop(database1) rescue true
    subject.drop(database2) rescue true
  end

  # This might be an odd place for this test
  # This method is on Apartment::Database itself, the rest are for the specific adapters
  describe "#adapter" do

    before do
      Apartment::Database.reload!
      Apartment::Database.config = config.symbolize_keys
    end
    
    after do
      Apartment::Database.reload! # extra reload so we get a new config for each test
    end

    it "should load the proper adapter" do
      Apartment::Database.adapter.should be_a(subject.class)
    end

    it "should raise runtime error with invalid adapter specified" do
      Apartment::Database.stub(:config).and_return config.merge(:adapter => 'unkown')

      expect {
        Apartment::Database.adapter
      }.to raise_error(RuntimeError)
    end

  end

  # Create requires that a `database_names` method be defined in the calling example group
  # This ensures that each adapter can independently verify that the db is created in this test
  describe "#create" do

    it "should create the new database" do
      database_names.should include(database1)
    end

    it "should load schema.rb to new schema" do
      subject.process database1 do
        ActiveRecord::Base.connection.tables.should include('companies')
      end
    end

    it "should reset connection when finished" do
      subject.current_database.should_not == database1
    end

    it "should seed data" do
      subject.process(database1) do
        User.count.should be > 0
      end
    end

  end

  describe "#current_database" do

    it "should return the current database name" do
      subject.process database1 do
        subject.current_database.should == database1
      end
    end
  end

  describe "#drop" do

    it "should delete the database" do
      subject.switch database1    # can't drop db we're currently connected to, ensure these are different
      subject.drop database2

      database_names.should_not include(database2)
    end

    it "should raise an error for unkown database" do
      expect {
        subject.drop "unknown_database"
      }.to raise_error(Apartment::DatabaseNotFound)
    end
  end

  describe "#process" do

    it "should connect to new database" do
      subject.process database1 do
        subject.current_database.should == database1
      end
    end

    it "should switch back to previous database when done" do
      subject.switch database1
      subject.process(database2)
      subject.current_database.should == database1
    end
  end

  describe "#reset" do

    it "should reset connection" do
      database = ActiveRecord::Base.connection.current_database
      subject.switch(database1)
      subject.reset
      ActiveRecord::Base.connection.current_database.should == database
    end

  end

  describe "#seed" do

    let(:database3){ "database3" }

    before do
      Apartment.seed_after_create = false # disable auto seeding
    end

    after do
      subject.drop(database3)
    end

    it "should load seed data" do
      subject.create(database3)

      subject.process(database3) do
        User.count.should == 0
        subject.seed
        User.count.should > 0
      end
    end
  end

  describe "#switch" do

    it "should connect to new database" do
      subject.switch database1
      subject.current_database.should == database1
    end

    it "should fail with invalid database" do
      expect {
        subject.switch('some_nonexistent_database')
      }.to raise_error(Apartment::DatabaseNotFound)
    end    
  end
    
end
