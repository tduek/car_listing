class Listing < ActiveRecord::Base
  include ActiveSupport::Inflector

  attr_accessible :is_owner, :miles, :model_id, :phone, :price, :year, :zipcode, :post_date, :make_id, :title, :description, :vin, :transmission

  belongs_to :seller, class_name: 'User', foreign_key: :seller_id
  has_one :zip, through: :seller, source: :zip

  belongs_to :make, class_name: "Subdivision", foreign_key: :make_id
  belongs_to :model, class_name: "Subdivision", foreign_key: :model_id

  has_one :main_pic, class_name: "Pic", conditions: '"pics"."ord" = 1'
  has_many :pics, dependent: :destroy

  has_many :favorites
  has_many :users_who_have_favorited, through: :favorites, source: :user

  before_validation :fix_year
  after_validation :remove_phone_if_same_as_seller

  validate :ensure_phone_format, if: :phone
  validates :year, :make_id, :model_id, :miles, :transmission, :phone, :price, :title, :description, :zipcode, presence: true
  validates :zipcode, :year, :miles, :price, numericality: {message: "must be a number"}
  validates :year, inclusion: {in: 1920..Time.now.year, message: "must be between 1920 - #{Time.now.year + 1}"}
  validate :miles_arent_shortened
  validates :is_owner, inclusion: {in: [true, false], message: "must specify whether it's 'by-owner or not"}
  validates :title, length: 15..100
  validates :description, length: {minimum: 150}

  SORT_OPTIONS = [["oldest first", "post_date_asc"],
                  ["newest first", "post_date_desc"],
                  ["lowest price", "price_asc"],
                  ["highest price", "price_desc"],
                  ["distance", "distance"],
                  ["best deal", "best_deal"]]

  # def self.eager_load_pics(listings)
  #   listings = listings.to_a
  #
  #   pics = Pic.where(listing_id: listings.map(&:id))
  #   main_pics, all_pics = {}, Hash.new { |h, k| h[k] = [] }
  #   pics.each do |pic|
  #     main_pics[listing.id] = pic if pic.ord == 1
  #     all_pics[pic.listing_id] << pic
  #   end
  #
  #   listings.each do |listing|
  #     def listing.main_pic; main_pics[listing.id]; end
  #     def listing.pics; all_pics[listing.id]; end
  #   end
  #
  #   listings
  # end

  def self.cached_count(refresh = false)
    if !refresh && @cached_count && @cached_count_updated_at > 2.hours.ago
      return @cached_count
    end

    @cached_count_updated_at = Time.now
    @cached_count = Listing.count
  end

  def miles_arent_shortened
    msg = "must specify the full number of miles (ie: 49000 miles and not just 49 or 49k). The system doesn't allow a car of this year to have less than "
    if year && miles
      if miles < 300 && year < Time.now.year - 2
        errors[:miles] << msg + "300 miles"
      elsif miles < 120 && year == Time.now.year - 2
        errors[:miles] << msg + "120 miles"
      elsif miles < 34 && year == Time.now.year - 1
        errors[:miles] << msg + "34 miles"
      end
    end
  end

  def by_owner?
    if seller.present?
      !seller.is_dealer?
    else
      !!self.is_owner
    end
  end

  def ensure_phone_format
    unless self.phone.to_s.length.between?(10, 11)
      errors[:phone] << "is invalid."
    end
  end

  def fix_year
    if self.year && self.year.to_s.length == 2
      self.year = self.year.to_s.gsub(/\D/, "")
      if self.year.to_i <= (Time.now.year + 1) % 100
        self.year = "19#{self.year}".to_i
      else
        self.year = "20#{self.year}".to_i
      end
    end

    true
  end

  def remove_phone_if_same_as_seller
    if self.phone == self.seller.phone
      self.phone = nil
    end

    true
  end

  def self.within_miles_from_zip(dist, zip)
   Listing.select('users_with_dist.distance')
          .joins(<<-SQL)
            INNER JOIN (#{ User.within_miles_from_zip(dist, zip).to_sql }) AS users_with_dist
                    ON users_with_dist.id=listings.seller_id
          SQL
  end

  <<-SQL
      SELECT users_with_dist.distance, listings.*, (
              sum(CASE WHEN inner_listings.price > listings.price
                  THEN 1 ELSE 0 END
              ) / count(inner_listings.*)::decimal
            ) AS deal_ratio
       FROM "listings"
       INNER JOIN (
         SELECT users.*, near_zips.distance
         FROM "users"
         INNER JOIN (
           SELECT zips_with_distance.*
           FROM (
             SELECT zips_to.*, CASE zips_to.code
               WHEN '10009' THEN 0
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
             FROM zips AS zips_from
             CROSS JOIN zips AS zips_to
             WHERE (zips_from.code=10009)
           ) AS zips_with_distance
           WHERE (zips_with_distance.distance <= 50) AND (
             (zips_with_distance.lat BETWEEN 39.9909058823529411 AND 41.4614941176470589) AND
             (zips_with_distance.long BETWEEN -75.408171428571429 AND -72.551028571428571))
         ) AS near_zips
         ON near_zips.code=users.zipcode
       ) AS users_with_dist
       ON users_with_dist.id=listings.seller_id
       INNER JOIN listings AS inner_listings
       ON listings.year=inner_listings.year
       AND listings.model_id=inner_listings.model_id
       WHERE (listings.model_id IS NOT NULL)
       GROUP BY listings.id
       LIMIT 25
       OFFSET 0


  SQL


  # def self.within_miles_from_zip(dist, zip)
  #  Listing.select('listings.*')
  #         .where("listings.zipcode IN (#{Zip.near(dist, zip).to_sql})")
  # end

  def self.with_deal_ratio
    result = self.select(<<-SQL)
      listings.*, (
        SELECT (sum(CASE
                   WHEN inner_listings.price > listings.price
                   THEN 1 ELSE 0 END) / count(inner_listings.id)::decimal
                   ) AS deal_ratio
        FROM listings AS inner_listings
        WHERE inner_listings.model_id=listings.model_id
          AND inner_listings.year=listings.year
       )
     SQL

    def result.cheap_total_count
      select_val = "COUNT(listings.id)"
      join_val = self.joins_values.join(' ')
      where_val = self.where_values
                      .map { |w| case w; when Arel::Nodes::Node; w.to_sql; else w; end }
                      .reject { |w| w[/RANDOM ID generation/] }
                      .join(' AND ')

      Listing.count_by_sql(<<-SQL)
        SELECT #{select_val}
        FROM listings
        #{join_val}
        WHERE #{where_val}
      SQL
    end

    result
  end

  def self.search(terms, page = nil)
    page = 1 if [nil, 0].include?(page)

    if terms[:zip] && terms[:zip].to_s.length == 5 && Zip.find_by_code(terms[:zip])
      dist = terms[:dist] && terms[:dist] > 0 ? terms[:dist] : 3500
      result = Listing.within_miles_from_zip(dist, terms[:zip])
    else
      result = Listing
    end

    results = result.where('listings.model_id IS NOT NULL').with_deal_ratio
                    # .includes(:pics, :main_pic, :make, :model, :zip)


    results = results.page(page) unless terms.keys.empty?

    if terms[:year_from].to_i > 0 && terms[:year_to].to_i > 0
      results = results.where(year: terms[:year_from]..terms[:year_to])
    elsif terms[:year_from].to_i > 0
      results = results.where("listings.year >= '#{terms[:year_from]}'")
    elsif terms[:year_to].to_i > 0
      results = results.where("listings.year <= '#{terms[:year_to]}'")
    end

    if terms[:make_id].to_i > 0
      results = results.where(make_id: terms[:make_id])
    end

    if terms[:model_id].to_i > 0
      results = results.where(model_id: terms[:model_id])
    end

    if terms[:price_from].to_i > 0 && terms[:price_to].to_i > 0
      results = results.where(price: terms[:price_from]..terms[:price_to])
    elsif terms[:price_from].to_i > 0
      results = results.where("listings.price >= '#{terms[:price_from]}'")
    elsif terms[:price_to].to_i > 0
      results = results.where("listings.price <= '#{terms[:price_to]}'")
    end

    results.order_values = []
    if terms[:sort] == 'distance' && terms[:zip].to_s.length != 5
      terms[:sort] = ''
    end

    sorts = {'post_date_asc' => 'listings.post_date ASC',
             'post_date_desc' => 'istings.post_date DESC',
             'price_asc' => 'listings.price ASC',
             'price_desc' => 'listings.price DESC',
             'distance' => 'near_zips.distance ASC',
             'best_deal' => 'deal_ratio DESC'}

    if sorts[terms[:sort]]
      results = results.order(sorts[terms[:sort]])
    elsif terms.count == 0 || (terms[:sort] && terms.count == 1)
      results = results.where(<<-SQL).limit(25)
        listings.id IN (
          -- RANDOM ID generation
          SELECT floor(random() * (max_id - min_id + 1))::integer + min_id
          FROM generate_series(1, 100),
               (SELECT max(listings.id) AS max_id, min(listings.id) AS min_id
                FROM listings) AS s1
          )
      SQL
    end

    results
  end

  def transmission
    case read_attribute(:transmission)
    when 1; 'Automatic'
    when 2; 'Manual'
    else; nil
    end
  end

  def transmission=(tranny)
    if tranny && [1, 2].include?(tranny.to_i)
      write_attribute(:transmission, tranny.to_i)
    elsif tranny.is_a?(String) && tranny[/auto/i]
      write_attribute(:transmission, 1)
    else tranny.is_a?(String) && tranny[/manual/i]
      write_attribute(:transmission, 2)
    end
  end

  def phone
    phone = read_attribute(:phone)
    return phone if phone

    self.seller && self.seller.phone
  end

  def location
    location = "#{ self.zip.city }, #{ self.zip.st }"
    if self.respond_to?(:distance)
      location += " (#{ self.distance.to_f.round } #{ 'mile'.pluralize(self.distance.to_f.round) } away)"
    end

    location
  end

  def post_date_iso8601
    self.created_at.getutc.iso8601
  end

  def is_favorite?

  end

  def vin
    vin = read_attribute(:vin)
    if vin && vin.length > 0
      vin
    else
      nil
    end
  end

  def ymm
    [self.year, self.make && self.make.name, self.model && self.model.name].compact.join(" ")
  end

end
