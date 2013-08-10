class IndexForeignKeys < ActiveRecord::Migration
  def change
    add_index :listings, :make_id
    add_index :listings, :model_id
    add_index :listings, :year
    add_index :listings, :price
    
    add_index :pics, :scraping_id
    add_index :pics, :listing_id
    
    add_index :subdivisions, :parent_id
    add_index :subdivisions, :level
    
    add_index :spellings, :subdivision_id
  end
end
