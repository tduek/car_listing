class AddIsRealUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_real_user, :boolean
  end
end
