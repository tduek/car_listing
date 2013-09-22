class Subdivision < ActiveRecord::Base
  attr_accessible :name, :parent_id, :level

  has_many :children, class_name: "Subdivision", foreign_key: :parent_id

  belongs_to :parent, class_name: "Subdivision", foreign_key: :parent_id

  has_many :spellings


  def listings(years = nil)
    result = Listing.where("listings.make_id=? OR listings.model_id=?", self.id, self.id)

    result = result.where(year: years) if years
    result
  end

  def average_price(args)
    self.listings(args[:years]).average("listings.price").to_i
  end

  def std_dev(args)
    self.listings(args[:years]).
  end

  def stats(args)
    #preserve streak!!!
    ActiveRecord::Base.connection.execute("SELECT \"results.")
  end

end
