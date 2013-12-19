class AddIsActivatedAndActivationTokenAndActivationTokenSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_activated, :boolean
    add_column :users, :activation_token, :string
    add_column :users, :activation_email_sent_at, :datetime
  end
end
