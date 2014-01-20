class CreatePics < ActiveRecord::Migration
  def change
    create_table :pics do |t|
      t.integer :listing_id
      t.attachment :file

      t.timestamps
    end

    add_index :pics, :listing_id
  end
end
