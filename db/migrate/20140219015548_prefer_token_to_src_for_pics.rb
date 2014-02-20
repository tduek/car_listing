class PreferTokenToSrcForPics < ActiveRecord::Migration
  def up
    remove_column :pics, :src
    add_column :pics, :token, :string
  end

  def down
    remove_column :pics, :token
    add_column :pics, :src, :text
  end

end
