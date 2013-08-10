class AddIndexOnGuidToScrapings < ActiveRecord::Migration
  def change
    add_index :scrapings, :guid
  end
end
