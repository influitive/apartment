require 'delayed_job'
require 'apartment/delayed_job/active_record'   # ensure that our AR hooks are loaded when queueing

module Apartment
  module Delayed
    module Job

      # Will enqueue a job ensuring that it happens within the main 'public' database
      #
      # Note that this should not longer be required for versions >= 0.11.0 when using postgresql schemas
      #
      def self.enqueue(payload_object, options = {})
        Apartment::Database.process do
          ::Delayed::Job.enqueue(payload_object, options)
        end
      end

    end
  end
end