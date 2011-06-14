module Apartment
  
  module Test
    
    def self.migrate
      ActiveRecord::Migrator.migrate Rails.root + ActiveRecord::Migrator.migrations_path
    end
  end
end