class CreateYears < ActiveRecord::Migration
  def change
    create_table :years do |t|
      t.integer :year
      t.integer :model_id

      t.timestamps
    end
    add_index :years, :model_id
  end
end
