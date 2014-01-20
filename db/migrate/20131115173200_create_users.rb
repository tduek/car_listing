class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :fname
      t.string :lname
      t.string :email
      t.string :phone
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.integer :zip
      t.string :password_digest
      t.string :reset_password_token
      t.boolean :is_activated
      t.string :activation_token
      t.datetime :activation_email_sent_at
      t.boolean :is_dealer

      t.timestamps
    end
  end
end
