module Apartment
  module Delayed
    module Job
      
      # Before and after hooks for performing Delayed Jobs within a particular apartment database
      module Hooks
        
        def before
          Apartment::Database.switch(Apartment::Database.current_database)
        end
        
        def after
          Apartment::Database.reset
        end
        
      end
    end
  end
end