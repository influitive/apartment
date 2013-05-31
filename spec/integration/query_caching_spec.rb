require 'spec_helper'

describe 'query caching' do
  before do
    Apartment.configure do |config|
      config.excluded_models = ["Company"]
      config.database_names = lambda{ Company.scoped.collect(&:database) }
    end

    db_names.each do |db_name|
      Apartment::Database.create(db_name)
      Company.create :database => db_name
    end
  end

  after do
    db_names.each{ |db| Apartment::Database.drop(db) }
    Company.delete_all
  end

  let(:db_names) { 2.times.map{ Apartment::Test.next_db } }

  it 'clears the ActiveRecord::QueryCache after switching databases' do
    db_names.each do |db_name|
      Apartment::Database.switch db_name
      User.create! name: db_name
    end

    ActiveRecord::Base.connection.enable_query_cache!

    Apartment::Database.switch db_names.first
    User.find_by_name(db_names.first).name.should == db_names.first

    Apartment::Database.switch db_names.last
    User.find_by_name(db_names.first).should be_nil
  end
end