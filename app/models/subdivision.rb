class Subdivision < ActiveRecord::Base
  attr_accessible :name, :parent_id, :level

  has_many :children, class_name: 'Subdivision', foreign_key: :parent_id

  # ONLY CALLABLE ON MAKES - level = 0
  has_many :active_models,
    class_name: 'Subdivision',
    foreign_key: :parent_id,
    conditions: <<-SQL
      subdivisions.id IN (
        SELECT DISTINCT
          listings.model_id
        FROM
          listings
      )
    SQL

  belongs_to :parent, class_name: "Subdivision", foreign_key: :parent_id

  has_many :spellings

  scope :all_makes, -> { where(parent_id: nil).order(:name) }
  scope :all_models, -> { where(level: 1).order(:name) }

  scope :makes,  -> do
                       where(parent_id: nil)
                       .order(:name)
                       .joins(<<-SQL)
                         INNER JOIN (
                           SELECT DISTINCT
                             listings.make_id
                           FROM
                             listings
                         )
                         AS listings_make_ids
                         ON listings_make_ids.make_id=subdivisions.id
                       SQL
                    end

  scope :models, -> do
                      where(level: 1)
                      .order(:name)
                      .joins(<<-SQL)
                        INNER JOIN (
                          SELECT DISTINCT
                            listings.model_id
                          FROM listings
                        ) AS listings_model_ids
                        ON listings_model_ids.model_id=subdivisions.id
                      SQL
                    end


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

  # Listing.find_by_sql(
  #   "SELECT listings.*
  #      FROM listings
  #     WHERE listings.model_id=198
  #       AND listings.year=2004
  #       AND listings.price < (
  #           SELECT avg(listings.price)-stddev_samp(listings.price)
  #             FROM listings
  #            WHERE listings.model_id=198
  #         GROUP BY listings.make_id)"
  #       ).count

end
