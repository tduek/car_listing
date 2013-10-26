class CreateSubdivisions < ActiveRecord::Migration
  def change
    create_table :subdivisions do |t|
      t.string :name
      t.integer :parent_id
      t.integer :level

      t.timestamps
    end

    add_index :subdivisions, :parent_id
    add_index :subdivisions, :level
  end
end
