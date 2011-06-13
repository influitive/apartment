module Apartment
  
  module Adapters
    
    class PostgresqlAdapter < AbstractAdapter
      
      def use_schemas?
        Config.use_postgres_schemas
      end
    end
    
  end
end