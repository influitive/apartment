require 'spec_helper'
require 'rake'

describe "apartment rake tasks" do
  
  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    load 'tasks/apartment.rake'
    Rake::Task.define_task(:environment)    # stub out loading rails environment
  end
  
  after do
    Rake.application = nil
  end
  
  let(:version){ '1234' }
  
  context 'database migration' do
    
    def company(db)
      stub('Company', :database => db, :name => db)
    end
    
    let(:companies){ [company('company1'), company('company2'), company('company3')] }
    let(:company_count){ companies.length }
    
    before do
      Admin::Company.stub(:where).and_return stub('Relation', :select => companies)
    end
    
    describe "apartment:migrate" do
      before do
        ActiveRecord::Migrator.stub(:migrate)   # don't care about this
      end
      
      it "should migrate all multi-tenant dbs" do
        Apartment::Database.should_receive(:migrate).exactly(company_count).times
        @rake['apartment:migrate'].invoke
      end
    end
    
    describe "apartment:migrate:up" do
      
      context "without a version" do
        before do
          ENV['VERSION'] = nil
        end
      
        it "requires a version to migrate to" do
          lambda{
            @rake['apartment:migrate:up'].invoke
          }.should raise_error("VERSION is required")
        end
      end
      
      context "with version" do
        
        before do
          ENV['VERSION'] = version
        end
        
        it "migrates up to a specific version" do
          Apartment::Database.should_receive(:migrate_up).with(anything, version.to_i).exactly(company_count).times
          @rake['apartment:migrate:up'].invoke
        end
      end
    end
    
    describe "apartment:migrate:down" do
      
      context "without a version" do
        before do
          ENV['VERSION'] = nil
        end
        
        it "requires a version to migrate to" do
          lambda{
            @rake['apartment:migrate:down'].invoke
          }.should raise_error("VERSION is required")
        end
      end
        
      context "with version" do
        
        before do
          ENV['VERSION'] = version
        end
        
        it "migrates up to a specific version" do
          Apartment::Database.should_receive(:migrate_down).with(anything, version.to_i).exactly(company_count).times
          @rake['apartment:migrate:down'].invoke
        end
      end
    end
    
    describe "apartment:rollback" do
      
      let(:step){ '3' }
      
      it "should rollback dbs" do
        Apartment::Database.should_receive(:rollback).exactly(company_count).times
        @rake['apartment:rollback'].invoke
      end
      
      it "should rollback dbs STEP amt" do
        Apartment::Database.should_receive(:rollback).with(anything, step.to_i).exactly(company_count).times
        ENV['STEP'] = step
        @rake['apartment:rollback'].invoke
      end
    end
  end
  
end