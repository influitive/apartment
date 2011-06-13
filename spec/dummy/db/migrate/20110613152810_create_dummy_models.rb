class CreateDummyModels < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.boolean :dummy, :default => true
    end
    
    create_table :users do |t|
      t.boolean :dummy, :default => true
    end
    
  end

  def self.down
    drop_table :companies
    drop_table :users
  end
end
