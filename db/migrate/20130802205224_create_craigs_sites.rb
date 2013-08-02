class CreateCraigsSites < ActiveRecord::Migration
  def change
    create_table :craigs_sites do |t|
      t.string :city
      t.string :city_for_url
      t.integer :zip
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
