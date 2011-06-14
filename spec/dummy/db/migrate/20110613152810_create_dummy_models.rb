class CreateDummyModels < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.boolean :dummy
      t.string :database
    end
    
    create_table :users do |t|
      t.boolean :dummy
    end
    
  end

  def self.down
    drop_table :companies
    drop_table :users
  end
end
