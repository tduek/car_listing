class Zip < ActiveRecord::Base
  attr_accessible :city, :code, :lat, :long, :st, :state

  has_many :listings, primary_key: :code, foreign_key: :zipcode

  def self.state_abbreviations
    select(:st).order(:st).uniq.map(&:st)
  end

  def self.near(distance, zip)
    zip_model = Zip.find_by_code(zip)
    rectangle_constraints = [
      zip_model.lat - (distance / 68.0),
      zip_model.lat + (distance / 68.0),
      zip_model.long - (distance / 35.0),
      zip_model.long + (distance / 35.0)
    ]

    Zip.select('zips_with_distance.*')
       .from("(#{zips_with_distance_from(zip).to_sql}) AS zips_with_distance")
       .where(['zips_with_distance.distance <= ?', distance])
       .where(<<-SQL, *rectangle_constraints)
         (zips_with_distance.lat BETWEEN ? AND ?) AND
         (zips_with_distance.long BETWEEN ? AND ?)
       SQL
  end

  def self.zips_with_distance_from(zip)

    Zip.select(<<-SQL)
          zips_to.*, CASE zips_to.code
          WHEN '#{zip}' THEN 0
          ELSE acos(
                 cos(radians(zips_from.lat)) *
                 cos(radians(zips_from.long))*
                 cos(radians(zips_to.lat))   *
                 cos(radians(zips_to.long))  +
                 cos(radians(zips_from.lat)) *
                 sin(radians(zips_from.long))*
                 cos(radians(zips_to.lat))   *
                 sin(radians(zips_to.long))  +
                 sin(radians(zips_from.lat)) *
                 sin(radians(zips_to.lat))
               ) * 3982 * 1.17
          END AS distance
        SQL
        .from('zips AS zips_from CROSS JOIN zips AS zips_to')
        .where('zips_from.code=?', zip)
  end


# acos(
#   cos(radians(zips_from.lat)) *
#   cos(radians(zips_from.long))*
#   cos(radians(zips_to.lat))   *
#   cos(radians(zips_to.long))  +
#   cos(radians(zips_from.lat)) *
#   sin(radians(zips_from.long))*
#   cos(radians(zips_to.lat))   *
#   sin(radians(zips_to.long))  +
#   sin(radians(zips_from.lat)) *
#   sin(radians(zips_to.lat))
#  ) * 3982 * 1.17
#
#   a = sin²(Δlat/2) + cos(lat1)⋅cos(lat2)⋅sin²(Δlong/2)
#   c = 2⋅atan2(√a, √(1−a))
#   d = R⋅c
#
#   d = R*(2*atan2(√a, √(1−a)))
#   d/R = (2*atan2(√a, √(1−a)))
#   d/(2*R) = atan2(√a, √(1−a))
#   √a =

end
