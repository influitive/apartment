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

          # sometimes we manually drop these schemas in testing, don't care if we can't drop, hence rescue
          subject.drop(db1) rescue true
          subject.drop(db2) rescue true
        end
      end

      %w{subject tenant_names default_tenant}.each do |method|
        define_method method do
          raise "You must define a `#{method}` method in your host group"
        end unless defined?(method)
      end
    end
  end
end
