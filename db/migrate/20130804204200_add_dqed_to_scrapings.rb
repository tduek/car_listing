class AddDqedToScrapings < ActiveRecord::Migration
  def change
    add_column :scrapings, :dqed, :boolean, default: false
  end
end
