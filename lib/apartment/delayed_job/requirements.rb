require 'apartment/delayed_job/enqueue'

module Apartment
  module Delayed
    
    # Mix this module into any ActiveRecord model that gets serialized by DJ
    module Requirements
      attr_accessor :database
      
      def self.included(klass)
        klass.after_find :set_database      # set db when records are pulled so they deserialize properly
        klass.before_save :set_database     # set db before records are saved so that they also get deserialized properly 
      end
      
    private
    
      def set_database
        @database = Apartment::Database.current_database
      end
    
    end
  end
end