class AddPriceToScrapings < ActiveRecord::Migration
  def change
    add_column :scrapings, :price, :integer
  end
end
