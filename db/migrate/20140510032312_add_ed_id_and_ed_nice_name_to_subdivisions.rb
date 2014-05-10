class AddEdIdAndEdNiceNameToSubdivisions < ActiveRecord::Migration
  def change
    add_column :subdivisions, :ed_id, :string
    add_column :subdivisions, :ed_niceName, :string
  end
end
