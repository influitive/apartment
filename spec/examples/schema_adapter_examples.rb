# The following should be used in all adapter tests to ensure they conform to the proper Apartment::Database spec
# Note I'm not crazy about this implementation, it uses methods from the system under test to actually test itself
# Couldn't think of a better way to share functionality ??

shared_examples_for "an apartment schema adapter" do
  
  let(:schema1){ "schema1" }
  let(:schema2){ "schema2" }
  
  before(:all) do
    ActiveRecord::Base.establish_connection config
  end
  
  before do
    @default_schema = ActiveRecord::Base.connection.schema_search_path
    Apartment.use_postgres_schemas = true
    Apartment.prepend_environment = false   # disabled env prepending for most tests
    Apartment.seed_after_create = true      # to test seeding
    
    subject.create(schema1)
    subject.create(schema2)
  end
  
  after do
    # need to re-establish connection to default, because dropping a db that is currently connected to fails
    ActiveRecord::Base.establish_connection config
    subject.drop(schema1) rescue true
    subject.drop(schema2) rescue true
  end
  
  describe "#create" do
    
    it "should create new postgres schema" do
      ActiveRecord::Base.connection.execute("SELECT nspname FROM pg_namespace;").collect{|row| row['nspname']}.should include(schema1)
    end    
  end
  
  describe "#current_database" do
    
    it "should return the current schema name" do
      subject.switch(schema1)
      subject.current_database.should == schema1
    end
  end
  
  describe "#drop" do
    
    it "should delete the schema" do
      subject.drop schema1
      
      expect {
        subject.switch schema1
      }.to raise_error Apartment::SchemaNotFound
    end
    
    it "should raise error for unkown schema" do
      expect {
        subject.drop "unknown_schema"
      }.to raise_error Apartment::SchemaNotFound
    end
  end
  
  describe "#process" do
    
    it "should connect to new schema" do
      subject.process(schema1) do
        ActiveRecord::Base.connection.schema_search_path.should == schema1
      end
    end
    
    it "should reset if necessary" do
      subject.process(schema1)
      ActiveRecord::Base.connection.schema_search_path.should == @default_schema
    end
    
    it "should return to previous schema" do
      subject.switch(schema1)
      subject.process(schema2)
      ActiveRecord::Base.connection.schema_search_path.should == schema1
    end
  end
  
  describe "#reset" do
    
    it "should reset connection" do
      subject.switch(schema1)
      subject.reset
      ActiveRecord::Base.connection.schema_search_path.should == @default_schema
    end
  end
  
  describe "#switch" do
    
    it "should connect to new schema" do
      subject.switch(schema1)
      ActiveRecord::Base.connection.schema_search_path.should == schema1
    end
    
    it "should fail with invalid schema" do
      expect {
        subject.switch('some_nonexistent_schema')
      }.to raise_error Apartment::SchemaNotFound
    end
    
    it "should reset connection if database is nil" do
      subject.switch
      ActiveRecord::Base.connection.schema_search_path.should == @default_schema
    end
  end
  
  
  
  
end
