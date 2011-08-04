require 'spec_helper'
require 'delayed_job'
Delayed::Worker.guess_backend

describe Apartment::Delayed do
  
  # See apartment.yml file in dummy app config
  
  let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
  let(:database){ "some_new_database" }
  let(:database2){ "another_db" }
  
  before do
    ActiveRecord::Base.establish_connection config
    Apartment::Test.load_schema   # load the Rails schema in the public db schema
    Apartment::Database.stub(:config).and_return config   # Use postgresql database config for this test
    @schema_search_path = ActiveRecord::Base.connection.schema_search_path
    
    Apartment.configure do |config|
      config.use_postgres_schemas = true
    end
    
    Apartment::Database.create database
    Apartment::Database.create database2
  end
  
  after do
    Apartment::Test.drop_schema database
    Apartment::Test.drop_schema database2
    Apartment::Test.reset
  end
  
  describe Apartment::Delayed::Job do
    context "#enqueue" do
    
      before do
        Apartment::Database.reset
      end
    
      it "should queue up jobs in the public schema" do
        dj_count = Delayed::Job.count
        Apartment::Database.switch database
        Apartment::Delayed::Job.enqueue FakeDjClass.new
        Apartment::Database.reset
        
        Delayed::Job.count.should == dj_count + 1
      end
    
      it "should not queue jobs in the current schema" do
        Apartment::Database.switch database
        expect {
          Apartment::Delayed::Job.enqueue FakeDjClass.new
        }.to_not change(Delayed::Job, :count)        # because we will still be on the `database` schema, not public
      end
    end
  end
  
  describe Apartment::Delayed::Requirements do
    
    before do
      Apartment::Database.switch database
      User.send(:include, Apartment::Delayed::Requirements)
      User.create
    end
    
    it "should initialize a database attribute on a class" do
      user = User.first
      user.database.should == database
    end
    
    it "should not overwrite any previous after_initialize declarations" do
      User.class_eval do
        after_find :set_name
        
        def set_name
          self.name = "Some Name"
        end
      end
      
      user = User.first
      user.database.should == database
      user.name.should == "Some Name"
    end
    
    context "serialization" do
      it "should serialize the proper database attribute" do
        user_yaml = User.first.to_yaml
        Apartment::Database.switch database2
        user = YAML.load user_yaml
        user.database.should == database
      end
    end
  end
  
end