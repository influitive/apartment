require 'spec_helper'

describe Apartment::Tenant do
  context "using mysql", database: :mysql do

    before { subject.reload!(config) }

    describe "#adapter" do
      it "should load mysql adapter" do
        subject.adapter
        expect(Apartment::Adapters::Mysql2Adapter).to be_a(Class)
      end
    end

    # TODO this doesn't belong here, but there aren't integration tests currently for mysql
    # where to put???
    describe "exception recovery", :type => :request do
      before do
        subject.create db1
      end
      after{ subject.drop db1 }

      # it "should recover from incorrect database" do
      #   session = Capybara::Session.new(:rack_test, Capybara.app)
      #   session.visit("http://#{db1}.com")
      #   expect {
      #     session.visit("http://this-database-should-not-exist.com")
      #   }.to raise_error
      #   session.visit("http://#{db1}.com")
      # end
    end

    # TODO re-organize these tests
    context "with prefix and schemas" do
      describe "#create" do
        before do
          Apartment.configure do |config|
            config.prepend_environment = true
            config.use_schemas = true
          end

          subject.reload!(config)
        end

        after { subject.drop "db_with_prefix" rescue nil }

        it "should create a new database" do
          subject.create "db_with_prefix"
        end
      end
    end
  end

  context "using postgresql", database: :postgresql do
    before do
      Apartment.use_schemas = true
      subject.reload!(config)
    end

    describe "#adapter" do
      it "should load postgresql adapter" do
        expect(subject.adapter).to be_a(Apartment::Adapters::PostgresqlSchemaAdapter)
      end

      it "raises exception with invalid adapter specified" do
        subject.reload!(config.merge(adapter: 'unknown'))

        expect {
          Apartment::Tenant.adapter
        }.to raise_error(RuntimeError)
      end

      context "threadsafety" do
        before { subject.create db1 }
        after  { subject.drop   db1 }

        it 'has a threadsafe adapter' do
          subject.switch!(db1)
          thread = Thread.new { expect(subject.current).to eq(Apartment.default_tenant) }
          thread.join
          expect(subject.current).to eq(db1)
        end
      end
    end

    # TODO above spec are also with use_schemas=true
    context "with schemas" do
      before do
        Apartment.configure do |config|
          config.excluded_models = []
          config.use_schemas = true
          config.seed_after_create = true
        end
        subject.create db1
      end

      after{ subject.drop db1 }

      describe "#create" do
        it "should seed data" do
          subject.switch! db1
          expect(User.count).to be > 0
        end
      end

      describe "#switch!" do

        let(:x){ rand(3) }

        context "creating models" do

          before{ subject.create db2 }
          after{ subject.drop db2 }

          it "should create a model instance in the current schema" do
            subject.switch! db2
            db2_count = User.count + x.times{ User.create }

            subject.switch! db1
            db_count = User.count + x.times{ User.create }

            subject.switch! db2
            expect(User.count).to eq(db2_count)

            subject.switch! db1
            expect(User.count).to eq(db_count)
          end
        end

        context "with excluded models" do

          before do
            Apartment.configure do |config|
              config.excluded_models = ["Company"]
            end
            subject.init
          end

          after do
            # Apartment::Tenant.init creates per model connection.
            # Remove the connection after testing not to unintentionally keep the connection across tests.
            Apartment.excluded_models.each do |excluded_model|
              excluded_model.constantize.remove_connection
            end
          end

          it "should create excluded models in public schema" do
            subject.reset # ensure we're on public schema
            count = Company.count + x.times{ Company.create }

            subject.switch! db1
            x.times{ Company.create }
            expect(Company.count).to eq(count + x)
            subject.reset
            expect(Company.count).to eq(count + x)
          end
        end
      end
    end

    context "seed paths" do
      before do
        Apartment.configure do |config|
          config.excluded_models = []
          config.use_schemas = true
          config.seed_after_create = true
        end
      end

      after{ subject.drop db1 }

      it 'should seed from default path' do
        subject.create db1
        subject.switch! db1
        expect(User.count).to eq(3)
        expect(User.first.name).to eq('Some User 0')
      end

      it 'should seed from custom path' do
        Apartment.configure do |config|
          config.seed_data_file = "#{Rails.root}/db/seeds/import.rb"
        end
        subject.create db1
        subject.switch! db1
        expect(User.count).to eq(6)
        expect(User.first.name).to eq('Different User 0')
      end
    end
  end
end
