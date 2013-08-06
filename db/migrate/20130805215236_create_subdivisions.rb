class CreateSubdivisions < ActiveRecord::Migration
  def change
    create_table :subdivisions do |t|
      t.string :name
      t.integer :parent_id

      t.timestamps
    end
  end
end
