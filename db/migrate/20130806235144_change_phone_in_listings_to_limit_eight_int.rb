class ChangePhoneInListingsToLimitEightInt < ActiveRecord::Migration
  def up
    change_column :listings, :phone, :integer, limit: 8
  end

  def down
    change_column :listings, :phone, :integer, limit: 4
  end
end
