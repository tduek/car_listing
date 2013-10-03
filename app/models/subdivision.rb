class Subdivision < ActiveRecord::Base
  attr_accessible :name, :parent_id, :level

  has_many :children, class_name: "Subdivision", foreign_key: :parent_id

  belongs_to :parent, class_name: "Subdivision", foreign_key: :parent_id

  has_many :spellings


  def listings(years = nil)
    result = Listing.where("listings.make_id=? OR listings.model_id=?", self.id, self.id)

    years ? result.where(year: years) : result
  end

  def with_stats
    Subdivision.all_with_stats.find_by_id(self.id)
  end

  def self.all_with_stats(parent_id = nil)
    result = Subdivision.select("subdivisions.*,
                                 avg(listings.price) AS avg,
                                 stddev_pop(listings.price) AS std_dev")
                        .joins("INNER JOIN listings
                                        ON listings.model_id=subdivisions.id
                                        OR listings.make_id=subdivisions.id")
                        .group("subdivisions.id")
                        .having("count(listings.id) > 30")

    parent_id ? result.where(parent_id: parent_id) : result
  end

end
