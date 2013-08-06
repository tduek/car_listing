class CreateSpellings < ActiveRecord::Migration
  def change
    create_table :spellings do |t|
      t.string :string
      t.integer :subdivision_id

      t.timestamps
    end
  end
end
