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
    self.listings(args[:years])
  end

  def stats(year = nil)
    yr_string = year ? " AND listings.year=#{year}" : ""

    result = ActiveRecord::Base.connection.execute(
      "SELECT subdivisions.name AS name, avg(listings.price) AS avg, stddev_pop(listings.price) AS std_dev
         FROM subdivisions
        INNER JOIN listings
           ON listings.model_id=#{self.id}
           OR listings.make_id=#{self.id}
        WHERE subdivisions.id=#{self.id}#{yr_string}
        GROUP BY subdivisions.id
       HAVING count(listings.id) > 30")

    result.ntuples == 1 ? result[0] : {"name" => self.name,"avg" => nil, "std_dev" => nil}
  end

end
