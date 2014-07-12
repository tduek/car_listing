class AddIsActiveToListings < ActiveRecord::Migration
  def change
    add_column :listings, :is_active, :boolean, default: true

    add_index :listings, :is_active
  end
end
