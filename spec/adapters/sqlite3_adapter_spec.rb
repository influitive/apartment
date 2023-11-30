require 'spec_helper'
require 'apartment/adapters/sqlite3_adapter'

describe Apartment::Adapters::Sqlite3Adapter, database: :sqlite do
  unless defined?(JRUBY_VERSION)

    subject{ Apartment::Tenant.sqlite3_adapter config }

    context "using connections" do
      def tenant_names
        db_dir = File.expand_path("../../dummy/db", __FILE__)
        Dir.glob("#{db_dir}/*.sqlite3").map { |file| File.basename(file, '.sqlite3') }
      end

      let(:default_tenant) do
        subject.switch { File.basename(Apartment::Test.config['connections']['sqlite']['database'], '.sqlite3') }
      end

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a connection based apartment adapter"

      after(:all) do
        File.delete(Apartment::Test.config['connections']['sqlite']['database'])
      end
    end

    context "with prepend and append" do
      let(:default_dir) { File.expand_path(File.dirname(config[:database])) }
      describe "#prepend" do
        let (:db_name) { "db_with_prefix" }
        before do
          Apartment.configure do |config|
            config.prepend_environment = true
            config.append_environment = false
          end
        end

        after { subject.drop db_name rescue nil }

        it "should create a new database" do
          subject.create db_name

          expect(File.exist?("#{default_dir}/#{Rails.env}_#{db_name}.sqlite3")).to eq true
        end
      end

      describe "#neither" do
        let (:db_name) { "db_without_prefix_suffix" }
        before do
          Apartment.configure { |config| config.prepend_environment = config.append_environment = false }
        end

        after { subject.drop db_name rescue nil }

        it "should create a new database" do
          subject.create db_name

          expect(File.exist?("#{default_dir}/#{db_name}.sqlite3")).to eq true
        end
      end

      describe "#append" do
        let (:db_name) { "db_with_suffix" }
        before do
          Apartment.configure do |config|
            config.prepend_environment = false
            config.append_environment = true
          end
        end

        after { subject.drop db_name rescue nil }

        it "should create a new database" do
          subject.create db_name

          expect(File.exist?("#{default_dir}/#{db_name}_#{Rails.env}.sqlite3")).to eq true
        end
      end

    end

  end
end
