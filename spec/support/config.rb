module Apartment
  
  module Test
    
    def self.config
      @config ||= YAML.load_file('spec/config/database.yml')
    end
    
  end
  
end