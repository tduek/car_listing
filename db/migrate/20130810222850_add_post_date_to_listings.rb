class AddPostDateToListings < ActiveRecord::Migration
  def change
    add_column :listings, :post_date, :datetime
  end
end
