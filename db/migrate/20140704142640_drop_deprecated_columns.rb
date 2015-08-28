class DropDeprecatedColumns < ActiveRecord::Migration
  def up
    remove_column :listings, :is_owner
    remove_column :listings, :phone
    remove_column :listings, :zipcode
    remove_column :listings, :post_date
  end

  def down
    add_column :listings, :is_owner, :boolean
    add_column :listings, :post_date, :datetime
    add_column :listings, :phone, :integer, limit: 8
    add_column :listings, :zipcode, :integer
  end
end
