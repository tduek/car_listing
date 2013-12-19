class CreateUserSessions < ActiveRecord::Migration
  def change
    create_table :user_sessions do |t|
      t.string :token
      t.integer :user_id

      t.timestamps
    end
  end
end
