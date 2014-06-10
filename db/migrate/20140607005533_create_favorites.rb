class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :listing_id
      t.integer :user_id

      t.timestamps
    end

    add_index :favorites, [:listing_id, :user_id]
    add_index :favorites, :listing_id
    add_index :favorites, :user_id
  end

end
