class ChangeUsersPhoneToBigint < ActiveRecord::Migration
  def up
    add_column :users, :phone_tmp, :integer, limit: 8

    execute(<<-SQL)
      UPDATE users
      SET phone_tmp=phone::bigint
    SQL

    remove_column :users, :phone
    rename_column :users, :phone_tmp, :phone
  end

  def down
    change_column :users, :phone, :string
  end
end
