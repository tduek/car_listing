class AddBtreeIndexOnCreatedAtToListings < ActiveRecord::Migration
  def change
    add_index :listings, :created_at, using: :btree
  end
end
