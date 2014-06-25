class RenameZipToZipcodeInUsers < ActiveRecord::Migration
  def up
    rename_column :users, :zip, :zipcode
  end

  def down
    rename_column :users, :zipcode, :zip
  end
end
