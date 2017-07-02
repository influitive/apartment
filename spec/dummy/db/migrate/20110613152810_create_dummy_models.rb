migration_class = (ActiveRecord::VERSION::MAJOR >= 5) ?  ActiveRecord::Migration[4.2] : ActiveRecord::Migration
class CreateDummyModels < migration_class
  def self.up
    create_table :companies do |t|
      t.boolean :dummy
      t.string :database
    end

    create_table :users do |t|
      t.string :name
      t.datetime :birthdate
      t.string :sex
     end

     create_table :delayed_jobs do |t|
       t.integer  :priority,   :default => 0
       t.integer  :attempts,   :default => 0
       t.text     :handler
       t.text     :last_error
       t.datetime :run_at
       t.datetime :locked_at
       t.datetime :failed_at
       t.string   :locked_by
       t.datetime :created_at
       t.datetime :updated_at
       t.string   :queue
     end

     add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  end

  def self.down
    drop_table :companies
    drop_table :users
    drop_table :delayed_jobs
  end

end
