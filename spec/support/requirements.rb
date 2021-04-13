# frozen_string_literal: true

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
        before do
          subject.create(db1)
          subject.create(db2)
        end

        after do
          # Reset before dropping (can't drop a db you're connected to)
          subject.reset

          # sometimes we manually drop these schemas in testing, don't care if
          # we can't drop, hence rescue
          begin
            subject.drop(db1)
          rescue StandardError => _e
            true
          end

          begin
            subject.drop(db2)
          rescue StandardError => _e
            true
          end
        end
      end

      %w[subject tenant_names default_tenant].each do |method|
        next if defined?(method)

        define_method method do
          raise "You must define a `#{method}` method in your host group"
        end
      end
    end
  end
end
