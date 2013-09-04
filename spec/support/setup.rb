module Apartment
  module Spec
    module Setup

      def self.included(base)
        base.instance_eval do
          let(:config){ database_config }

          let(:db1){ Apartment::Test.next_db }
          let(:db2){ Apartment::Test.next_db }
          let(:connection){ ActiveRecord::Base.connection }

          before(:each) do
            Apartment::Database.reload!(config.symbolize_keys)
            ActiveRecord::Base.establish_connection config
          end

          after(:each) do
            Rails.configuration.database_configuration = {}
            ActiveRecord::Base.connection_pool.automatic_reconnect = false
            ActiveRecord::Base.connection_pool.disconnect!
            ActiveRecord::Base.connection_pool.automatic_reconnect = true

            Apartment.excluded_models.each do |model|
              klass = model.constantize
              klass.connection_pool.automatic_reconnect = false
              klass.connection_pool.disconnect!
              klass.connection_pool.automatic_reconnect = true
            end

            Apartment.reset
            Apartment::Database.reload!
          end
        end
      end

      def database_config
        db = example.metadata.fetch(:database, :postgresql)
        Apartment::Test.config['connections'][db.to_s].symbolize_keys
      end
    end
  end
end