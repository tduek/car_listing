class AddOrdToPics < ActiveRecord::Migration
  def change
    add_column :pics, :ord, :integer
  end
end
