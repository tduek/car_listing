class Subdivision < ActiveRecord::Base
  attr_accessible :name, :parent_id, :level

  has_many :children, class_name: "Subdivision", foreign_key: :parent_id

  belongs_to :parent, class_name: "Subdivision", foreign_key: :parent_id

  has_many :spellings

  def average_price(args)
    result = Listing.where("listings.make_id=? OR listings.model_id=?", id, id)
    result = result.where(year: args[:year]) if args[:year]
    result.average("listings.price").to_i

  end
end
