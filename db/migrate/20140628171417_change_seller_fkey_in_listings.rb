class ChangeSellerFkeyInListings < ActiveRecord::Migration
  def up
    rename_column :listings, :user_id, :seller_id
  end

  def down
    rename_column :listings, :seller_id, :user_id
  end
end