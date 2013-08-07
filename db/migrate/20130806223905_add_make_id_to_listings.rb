class AddMakeIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :make_id, :integer
  end
end
