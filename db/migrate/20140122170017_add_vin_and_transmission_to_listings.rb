class AddVinAndTransmissionToListings < ActiveRecord::Migration
  def change
    add_column :listings, :vin, :string
    add_column :listings, :transmission, :integer
  end
end
