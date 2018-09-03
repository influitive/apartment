migration_class = (ActiveRecord::VERSION::MAJOR >= 5) ?  ActiveRecord::Migration[4.2] : ActiveRecord::Migration
class CreateTableBooks < migration_class
  def up
    create_table :books do |t|
      t.string :name
      t.integer :pages
      t.datetime :published
    end
  end

  def down
    drop_table :books
  end
end
