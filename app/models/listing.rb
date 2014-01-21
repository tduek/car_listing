class Listing < ActiveRecord::Base
  attr_accessible :is_owner, :miles, :model_id, :phone, :price, :year, :zipcode, :post_date, :make_id, :title, :description

  belongs_to :user

  belongs_to :zip, primary_key: :code, foreign_key: :zipcode

  belongs_to :make, class_name: "Subdivision", foreign_key: :make_id
  belongs_to :model, class_name: "Subdivision", foreign_key: :model_id

  has_one :main_pic, class_name: "Pic", conditions: '"pics"."ord" = 1'
  has_many :pics

  before_validation :fix_year
  before_validation :format_phone
  before_validation :remove_phone_if_same_as_user

  validates :year, :make_id, :model_id, :miles, :price, :title, :description, :zipcode, presence: :true
  validates :year, inclusion: {in: (1920..Time.now.year+1).to_a}
  validates :title, length: 15..100
  validates :description, length: 25..150
  validates :zipcode, :year, :miles, :price, numericality: true

  def by_owner?
    (self.user && !self.user.is_dealer?) || self.is_owner
  end

  def format_phone
    self.phone = self.phone.gsub(/\D/, '').to_i
  end

  def remove_phone_if_same_as_user
    if self.phone == self.user.phone

    end
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
        results = results.order("listings.id DESC")
      end
    end

    results.order("listings.post_date DESC")
  end



  def name
    [self.year, self.make && self.make.name, self.model && self.model.name].compact.join(" ")
  end

end
