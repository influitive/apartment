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
        connection.schema_search_path.should include schema2
        connection.schema_search_path.should_not include "public"
        User.create
      end

      connection.schema_search_path.should_not include schema2

      subject.process(schema2){ User.count.should == @count + 1 }
    end

    describe "numeric database names" do
      specify "should be allowed" do
        expect {
          subject.create(1234)
        }.to_not raise_error
        database_names.should include("1234")
        # cleanup
      end

      after { subject.drop(1234) }

    end

  end

  describe "#drop" do
    it "should raise an error for unknown database" do
      expect {
        subject.drop "unknown_database"
      }.to raise_error(Apartment::SchemaNotFound)
    end

    describe "numeric dbs" do
      it "should be droppable" do
        subject.create(1234)
        expect {
          subject.drop(1234)
        }.to_not raise_error
        database_names.should_not include("1234")
      end
      after { subject.drop(1234) rescue nil }
    end
  end

  describe "#process" do
    it "should connect" do
      subject.process(schema1) do
        connection.schema_search_path.should include schema1
      end
    end

    it "should reset" do
      subject.process(schema1)
      connection.schema_search_path.should include public_schema
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
      connection.schema_search_path.should include schema1
    end

    it "should reset connection if database is nil" do
      subject.switch
      connection.schema_search_path.should include public_schema
    end

    describe "other schemas in search path" do
      let(:other_schema) { "other_schema" }
      before do
        subject.create(other_schema)
        @old_schema = subject.instance_variable_get(:@defaults)[:schema_search_path]
        subject.instance_variable_get(:@defaults)[:schema_search_path] += "," + other_schema
      end

      it "should maintain other schemas on switch" do
        subject.switch(schema1)
        connection.schema_search_path.should include other_schema
      end

      after do
        subject.instance_variable_get(:@defaults)[:schema_search_path] = @old_schema
        subject.drop(other_schema)
      end

      describe "with schema_to_switch specified" do
        before do
          Apartment.schema_to_switch = other_schema
          subject.switch(schema1)
        end

        after do
          # Reset the switch schema.
          Apartment.schema_to_switch = nil
        end

        it "should switch out the schema to switch rather than public" do
          connection.schema_search_path.should_not include other_schema
        end

        it "should retain the public schema" do
          connection.schema_search_path.should include "public"
        end

        it "should still switch to the switched schema" do
          connection.schema_search_path.should include schema1
        end
      end
    end

    it "should raise an error if schema is invalid" do
      expect {
        subject.switch 'unknown_schema'
      }.to raise_error(Apartment::SchemaNotFound)
    end

    describe "numeric dbs" do
      it "should connect" do
        subject.create(1234)
        expect {
          subject.switch(1234)
        }.to_not raise_error
      end
      after { subject.drop(1234) }
    end
  end

  describe "#current_database" do
    it "should return the current schema name" do
      subject.switch(schema1)
      subject.current_database.should == schema1
    end
  end



end