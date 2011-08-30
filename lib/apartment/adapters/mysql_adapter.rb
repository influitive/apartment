module Apartment

  module Database
    
    def self.mysql_adapter(config)
      Adapters::MysqlAdapter.new config, {}
    end
  end
  
  module Adapters
  
    class MysqlAdapter < AbstractAdapter
      
    end
    
  end
  
end