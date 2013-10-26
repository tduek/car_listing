class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.integer :year
      t.integer :make_id
      t.integer :model_id
      t.integer :price
      t.datetime :post_date
      t.boolean :is_owner
      t.integer :zipcode
      t.integer :miles
      t.integer :phone, limit: 8

      t.timestamps
    end

    add_index :listings, :make_id
    add_index :listings, :model_id
    add_index :listings, :year
    add_index :listings, :price
  end
end
