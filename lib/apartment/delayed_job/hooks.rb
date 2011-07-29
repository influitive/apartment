require 'apartment/delayed_job/enqueue'

module Apartment
  module Delayed
    module Job
      
      # Before and after hooks for performing Delayed Jobs within a particular apartment database
      # Include these in your delayed jobs models and make sure provide a @database attr that will be serialized by DJ
      module Hooks
        
        attr_accessor :database
        
        def before(job)
          Apartment::Database.switch(job.payload_object.database) if job.payload_object.database
        end
        
        def after
          Apartment::Database.reset
        end
        
      end
    end
  end
end