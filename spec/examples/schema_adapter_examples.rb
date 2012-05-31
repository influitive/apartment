require 'spec_helper'

shared_examples_for "a schema based apartment adapter" do
  include Apartment::Spec::AdapterRequirements

  let(:schema1){ db1 }
  let(:schema2){ db2 }
  let(:public_schema){ default_database }

  describe "#init" do

    it "should process model exclusions" do
      Apartment.configure do |config|
        config.excluded_models = ["Company"]
      end

      Apartment::Database.init

      Company.table_name.should == "public.companies"
    end
  end

  #
  #   Creates happen already in our before_filter
  #
  describe "#create" do

    it "should load schema.rb to new schema" do
      connection.schema_search_path = schema1
      connection.tables.should include('companies')
    end

    it "should yield to block if passed and reset" do
      subject.drop(schema2) # so we don't get errors on creation

      @count = 0  # set our variable so its visible in and outside of blocks

      subject.create(schema2) do
        @count = User.count
        connection.schema_search_path.should start_with schema2
        User.create
      end

      connection.schema_search_path.should_not start_with schema2

      subject.process(schema2){ User.count.should == @count + 1 }
    end

    context "numeric database names" do
      let(:db){ 1234 }
      it "should allow them" do
        expect {
          subject.create(db)
        }.to_not raise_error
        database_names.should include(db.to_s)
      end

      after{ subject.drop(db) }
    end

  end

  describe "#drop" do
    it "should raise an error for unknown database" do
      expect {
        subject.drop "unknown_database"
      }.to raise_error(Apartment::SchemaNotFound)
    end

    context "numeric database names" do
      let(:db){ 1234 }

      it "should be able to drop them" do
        subject.create(db)
        expect {
          subject.drop(db)
        }.to_not raise_error
        database_names.should_not include(db.to_s)
      end

      after { subject.drop(db) rescue nil }
    end
  end

  describe "#process" do
    it "should connect" do
      subject.process(schema1) do
        connection.schema_search_path.should start_with schema1
      end
    end

    it "should reset" do
      subject.process(schema1)
      connection.schema_search_path.should == public_schema
    end
  end

  describe "#reset" do
    it "should reset connection" do
      subject.switch(schema1)
      subject.reset
      connection.schema_search_path.should == public_schema
    end
  end

  describe "#switch" do
    it "should connect to new schema" do
      subject.switch(schema1)
      connection.schema_search_path.should start_with schema1
    end

    it "should reset connection if database is nil" do
      subject.switch
      connection.schema_search_path.should == public_schema
    end

    it "should raise an error if schema is invalid" do
      expect {
        subject.switch 'unknown_schema'
      }.to raise_error(Apartment::SchemaNotFound)
    end

    context "numeric databases" do
      let(:db){ 1234 }

      it "should connect to them" do
        subject.create(db)
        expect {
          subject.switch(db)
        }.to_not raise_error

        connection.schema_search_path.should start_with db.to_s
      end

      after{ subject.drop(db) }
    end
  end

  describe "#current_database" do
    it "should return the current schema name" do
      subject.switch(schema1)
      subject.current_database.should == schema1
    end
  end

end