require 'delayed_job'
require 'apartment/delayed_job/active_record'   # ensure that our AR hooks are loaded when queueing

module Apartment
  module Delayed
    module Job
      
      # Will enqueue a job ensuring that it happens within the public schema
      # This is a work-around due to the fact that DJ for some reason always
      # queues its jobs in the current_schema, rather than the public schema
      # as it is supposed to
      def self.enqueue(payload_object, options = {})
        Apartment::Database.process do
          ::Delayed::Job.enqueue(payload_object, options)
        end
      end
      
    end
  end
end