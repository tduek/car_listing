class AddNewEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :new_email, :string
  end
end
