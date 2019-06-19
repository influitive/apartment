migration_class = (ActiveRecord::VERSION::MAJOR >= 5) ?  ActiveRecord::Migration[4.2] : ActiveRecord::Migration
class CreatePublicTokens < migration_class
  def up
    create_table :public_tokens do |t|
      t.string :token
      t.integer :user_id, foreign_key: true
    end
  end

  def down
    drop_table :public_tokens
  end
end
