class RenameResetPasswordColumnsToForgotPassword < ActiveRecord::Migration
  def up
    rename_column :users, :reset_password_token, :forgot_password_token
    rename_column :users, :reset_password_email_sent_at, :forgot_password_email_sent_at
  end

  def down
    rename_column :users, :forgot_password_token, :reset_password_token
    rename_column :users, :forgot_password_email_sent_at, :reset_password_email_sent_at
  end
end
