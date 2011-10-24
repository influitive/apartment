require 'spec_helper'
require 'rake'

describe "apartment rake tasks" do
  
  before :all do
    Apartment::Test.migrate   # ensure we have latest schema in the public 
  end
  
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Dummy::Application.load_tasks
  end
  
  after do
    Rake.application = nil
  end
  
  before do
    Apartment.configure do |config|
      config.excluded_models = ["Company"]
      config.database_names = lambda{ Company.scoped.collect(&:database) }
    end
  end

  context "with x number of databases" do
    before do
      @db_names = []
      @x = 1 + rand(5).times do |x| 
        @db_names << db_name = "schema_#{x}"
        Apartment::Database.create db_name
        Company.create :database => db_name
      end
    end
    
    after do
      @db_names.each{ |db| Apartment::Test.drop_schema(db) }
      Company.delete_all
    end
    
    describe "#migrate" do
      it "should migrate all databases" do
        Apartment::Migrator.should_receive(:migrate).exactly(@db_names.length).times
        
        @rake['apartment:migrate'].invoke
      end
    end
    
    describe "#rollback" do
      it "should rollback all dbs" do
        @db_names.each do |name|
          Apartment::Migrator.should_receive(:rollback).with(name, anything)
        end
        
        @rake['apartment:rollback'].invoke
      end
    end
    
    describe "apartment:seed" do
      it "should seed all databases" do
        Apartment::Database.should_receive(:seed).exactly(@db_names.length).times
        
        @rake['apartment:seed'].invoke
      end
    end
    
  end
end