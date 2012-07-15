require 'spec_helper'
require 'rake'

describe "apartment rake tasks" do

  before do
    @rake = Rake::Application.new
    Rake.application = @rake
    Dummy::Application.load_tasks

    # somehow this misc.rake file gets lost in the shuffle
    # it defines a `rails_env` task that our db:migrate depends on
    # No idea why, but during the tests, we somehow lose this tasks, so we get an error when testing migrations
    # This is STUPID!
    load "rails/tasks/misc.rake"
  end

  after do
    Rake.application = nil
  end

  before do
    Apartment.configure do |config|
      config.excluded_models = ["Company"]
      config.database_names = lambda{ Company.scoped.collect(&:database) }
    end

    # fix up table name of shared/excluded models
    Company.table_name = 'public.companies'
  end

  context "with x number of databases" do

    let(:x){ 1 + rand(5) }    # random number of dbs to create
    let(:db_names){ x.times.map{ Apartment::Test.next_db } }
    let!(:company_count){ Company.count + db_names.length }

    before do
      db_names.collect do |db_name|
        Apartment::Database.create(db_name)
        Company.create :database => db_name
      end
    end

    after do
      db_names.each{ |db| Apartment::Database.drop(db) }
      Company.delete_all
    end

    describe "#migrate" do
      it "should migrate all databases" do
        Apartment::Migrator.should_receive(:migrate).exactly(company_count).times

        @rake['apartment:migrate'].invoke
      end
    end

    describe "#rollback" do
      it "should rollback all dbs" do
        db_names.each do |name|
          Apartment::Migrator.should_receive(:rollback).with(name, anything)
        end

        @rake['apartment:rollback'].invoke
        @rake['apartment:migrate'].invoke   # migrate again so that our next test 'seed' can run (requires migrations to be complete)
      end
    end

    describe "apartment:seed" do
      it "should seed all databases" do
        Apartment::Database.should_receive(:seed).exactly(company_count).times

        @rake['apartment:seed'].invoke
      end
    end

  end
end