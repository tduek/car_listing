class AddSrcToPics < ActiveRecord::Migration
  def change
    add_column :pics, :src, :text
  end
end
