class RenameZipToZipcodeInListings < ActiveRecord::Migration
  def up
    rename_column :listings, :zip, :zipcode
  end

  def down
    rename_column :listings, :zipcode, :zip
  end
end
