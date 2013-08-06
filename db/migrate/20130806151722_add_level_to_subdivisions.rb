class AddLevelToSubdivisions < ActiveRecord::Migration
  def change
    add_column :subdivisions, :level, :integer
  end
end
