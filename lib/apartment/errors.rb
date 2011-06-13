module Apartment
  
  # = Apartment Errors
  #
  # Generic Apartment exception class.
  class ApartmentError < StandarError; end
  
  
  # Rails when apartment cannot find the adapter specified in <tt>config/database.yml</tt>
  class AdapterNotFound < ApartmentError; end
  
  
end