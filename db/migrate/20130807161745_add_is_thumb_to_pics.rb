class AddIsThumbToPics < ActiveRecord::Migration
  def change
    add_column :pics, :is_thumb, :boolean
  end
end
