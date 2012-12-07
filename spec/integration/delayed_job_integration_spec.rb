require 'spec_helper'
require 'delayed_job'
require 'delayed_job_active_record'

describe Apartment::Delayed do

  # See apartment.yml file in dummy app config

  let(:config){ Apartment::Test.config['connections']['postgresql'].symbolize_keys }
  let(:database){ Apartment::Test.next_db }
  let(:database2){ Apartment::Test.next_db }

  before do
    ActiveRecord::Base.establish_connection config
    Apartment::Test.load_schema   # load the Rails schema in the public db schema
    Apartment::Database.stub(:config).and_return config   # Use postgresql database config for this test

    Apartment.configure do |config|
      config.use_schemas = true
    end

    Apartment::Database.create database
    Apartment::Database.create database2
  end

  after do
    Apartment::Test.drop_schema database
    Apartment::Test.drop_schema database2
    Apartment.reset
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

    it "should set the db on a new record before it saves" do
      user = User.create
      user.database.should == database
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

  describe Apartment::Delayed::Job::Hooks do

    let(:worker){ Delayed::Worker.new }
    let(:job){ Delayed::Job.enqueue User.new }

    it "should switch to previous db" do
      Apartment::Database.switch database
      worker.run(job)

      Apartment::Database.current_database.should == database
    end
  end

end