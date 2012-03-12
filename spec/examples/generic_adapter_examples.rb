require 'spec_helper'

shared_examples_for "a generic apartment adapter" do
  include Apartment::Spec::AdapterRequirements
  
  before{ Apartment.prepend_environment = false }
  
  #
  #   Creates happen already in our before_filter
  #
  describe "#create" do

    it "should create the new databases" do
      database_names.should include(db1)
      database_names.should include(db2)
    end

    it "should load schema.rb to new schema" do
      Apartment::Database.process(db1) do
        connection.tables.should include('companies')
      end
    end
    
    it "should yield to block if passed and reset" do
      subject.drop(db2) # so we don't get errors on creation

      @count = 0  # set our variable so its visible in and outside of blocks

      subject.create(db2) do
        @count = User.count
        Apartment::Database.current_database.should == db2
        User.create
      end
      
      Apartment::Database.current_database.should_not == db2

      subject.process(db2){ User.count.should == @count + 1 }
    end
  end
  
  describe "#drop" do
    it "should raise an error for unknown database" do
      expect {
        subject.drop "unknown_database"
      }.to raise_error(Apartment::ApartmentError)
    end
  end
end