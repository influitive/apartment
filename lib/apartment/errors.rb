module Apartment
  
  # = Apartment Errors
  #
  # Generic Apartment exception class.
  class ApartmentError < StandardError; end
  
  
  # Raised when apartment cannot find the adapter specified in <tt>config/database.yml</tt>
  class AdapterNotFound < ApartmentError; end
  
  # Raised when database cannot find the specified schema
  class SchemaNotFound < ApartmentError; end
  
  
end