class CreateScrapings < ActiveRecord::Migration
  def change
    create_table :scrapings do |t|
      t.string :title
      t.text :description
      t.string :url
      t.datetime :post_date
      t.integer :guid, limit: 8
      t.string :seller_type
      t.string :source
      t.integer :craigs_site_id
      t.boolean :parsed, default: false

      t.timestamps
    end
  end
end
