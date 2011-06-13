module Apartment
  
  module Adapters
  
    class AbstractAdapter
      
      # Whether or not to use postgresql schemas
      def use_schemas?
        false
      end
    end
  
  end
end