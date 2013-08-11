class CreateZips < ActiveRecord::Migration
  def change
    create_table :zips do |t|
      t.integer :code
      t.string :city
      t.string :state
      t.string :st
      t.decimal :lat
      t.decimal :long

      t.timestamps
    end
    add_index :zips, :code
    add_index :zips, :lat
    add_index :zips, :long
  end
end
