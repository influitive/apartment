module Apartment
  module Spec

    #
    #   Define the interface methods required to
    #   use an adapter shared example
    #
    #
    module AdapterRequirements

      extend ActiveSupport::Concern

      included do
        let(:db1){ Apartment::Test.next_db }
        let(:db2){ Apartment::Test.next_db }
        let(:connection){ ActiveRecord::Base.connection }

        before do
          Apartment::Database.reload!(config.symbolize_keys)
          ActiveRecord::Base.establish_connection config

          subject.create(db1)
          subject.create(db2)
        end

        after do
          # Reset before dropping (can't drop a db you're connected to)
          subject.reset

          # sometimes we manually drop these schemas in testing, don't care if we can't drop, hence rescue
          subject.drop(db1) rescue true
          subject.drop(db2) rescue true

          # This is annoying, but for each sublcass that establishes its own connection (ie Company for excluded models for connection based adapters)
          # a separate connection is maintained (clear_all_connections! doesn't appear to deal with these)
          # This causes problems because previous tests that established this connection could F up the next test, so we'll just remove them all for each test :(
          Apartment.excluded_models.each do |m|
            klass = m.constantize
            Apartment.connection_class.remove_connection(klass)
            klass.reset_table_name
          end
          ActiveRecord::Base.clear_all_connections!
        end
      end

      %w{subject config database_names default_database}.each do |method|
        define_method method do
          raise "You must define a `#{method}` method in your host group"
        end unless defined?(method)
      end

    end
  end
end