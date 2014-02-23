class Listing < ActiveRecord::Base
  attr_accessible :is_owner, :miles, :model_id, :phone, :price, :year, :zipcode, :post_date, :make_id, :title, :description, :vin, :transmission



  belongs_to :user

  belongs_to :zip, primary_key: :code, foreign_key: :zipcode

  belongs_to :make, class_name: "Subdivision", foreign_key: :make_id
  belongs_to :model, class_name: "Subdivision", foreign_key: :model_id

  has_one :main_pic, class_name: "Pic", conditions: '"pics"."ord" = 1'
  has_many :pics, dependent: :destroy

  before_validation :fix_year
  after_validation :remove_phone_if_same_as_user

  validate :ensure_phone_format, if: :phone
  validates :year, :make_id, :model_id, :miles, :transmission, :phone, :price, :title, :description, :zipcode, presence: true
  validates :zipcode, :year, :miles, :price, numericality: {message: "must be a number"}
  validates :year, inclusion: {in: 1920..Time.now.year, message: "must be between 1920 - #{Time.now.year + 1}"}
  validate :miles_arent_shortened
  validates :is_owner, inclusion: {in: [true, false], message: "must specify whether it's 'by-owner or not"}
  validates :title, length: 15..100
  validates :description, length: {minimum: 150}

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
    (self.user && !self.user.is_dealer?) || self.is_owner
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

  def remove_phone_if_same_as_user
    if self.phone == self.user.phone
      self.phone = nil
    end

    true
  end

  def self.within_miles_from_zip(dist, zip)
   Listing.select('listings.*, "near_zips"."distance"').
           joins("INNER JOIN (#{Zip.near(dist, zip).to_sql}) AS \"near_zips\" ON \"near_zips\".\"code\"=\"listings\".\"zipcode\"")
  end

  def self.search(terms, page)
    if terms[:zip] && terms[:zip].length == 5 && Zip.find_by_code(terms[:zip])
      dist = terms[:dist] && terms[:dist].length > 0 ? terms[:dist] : "3500"
      result = Listing.within_miles_from_zip(dist, terms[:zip])
    else
      result = Listing
    end

    results = result.where("listings.model_id IS NOT NULL").
                    includes(:pics, :main_pic, :make, :model, :zip).
                    page(page)

    if terms
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
      if terms[:sort] == "distance" && (terms[:zip] && terms[:zip].length != 5)
        terms[:sort] = ""
      end

      case terms[:sort]
      when "post_date_asc"
        results = results.order(:post_date)
      when "post_date_desc"
        results = results.order("listings.post_date DESC")
      when "price_asc"
        results = results.order(:price)
      when "price_desc"
        results = results.order("listings.price DESC")
      when "distance"
        results = results.order("near_zips.distance ASC")
      else
        results = results.order("listings.post_date ASC")
      end
    end

    results
  end

  def transmission
    case read_attribute(:transmission)
    when 1; 'Automatic'
    when 2; 'Manual'
    else; 'N/A'
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

  def vin
    vin = read_attribute(:vin)
    if vin && vin.length > 0
      vin
    else
      'N/A'
    end
  end

  def name
    [self.year, self.make && self.make.name, self.model && self.model.name].compact.join(" ")
  end

end
