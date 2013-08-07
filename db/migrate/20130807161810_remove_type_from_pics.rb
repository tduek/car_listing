class RemoveTypeFromPics < ActiveRecord::Migration
  def up
    remove_column :pics, :type
  end

  def down
    add_column :pics, :type, :integer
  end
end
