require 'spec_helper'
require 'apartment/adapters/sqlite3_adapter'

describe Apartment::Adapters::Sqlite3Adapter do
  unless defined?(JRUBY_VERSION)

    let(:config){ Apartment::Test.config['connections']['sqlite'].symbolize_keys }
    subject{ Apartment::Database.sqlite3_adapter config }

    context "using connections" do
      def database_names
        db_dir = File.expand_path("../../dummy/db", __FILE__)
        Dir.glob("#{db_dir}/*.sqlite3").map { |file| File.basename(file, '.sqlite3') }
      end

      let(:default_database) do
        subject.process { File.basename(Apartment::Test.config['connections']['sqlite']['database'], '.sqlite3') }
      end

      it_should_behave_like "a generic apartment adapter"
      it_should_behave_like "a connection based apartment adapter"

      after(:all) do
        File.delete(Apartment::Test.config['connections']['sqlite']['database'])
      end
    end
  end
end
