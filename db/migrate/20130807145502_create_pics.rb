class CreatePics < ActiveRecord::Migration
  def change
    create_table :pics do |t|
      t.string :src
      t.integer :listing_id
      t.boolean :is_thumb
      t.integer :thumb_for
      t.attachment :file

      t.timestamps
    end

    add_index :pics, :listing_id
  end
end
