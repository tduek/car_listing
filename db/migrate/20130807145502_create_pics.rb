class CreatePics < ActiveRecord::Migration
  def change
    create_table :pics do |t|
      t.string :src
      t.integer :listing_id
      t.integer :type
      t.integer :thumb_for

      t.timestamps
    end
  end
end
