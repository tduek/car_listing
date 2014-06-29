class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :model_id
      t.integer :mean
      t.integer :std_dev
      t.integer :pop
      t.integer :year

      t.timestamps
    end
  end
end
