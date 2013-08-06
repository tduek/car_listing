class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.integer :year
      t.integer :model_id
      t.integer :price
      t.boolean :is_owner
      t.integer :zip
      t.integer :miles
      t.integer :phone
      t.integer :scraping_id

      t.timestamps
    end
  end
end
