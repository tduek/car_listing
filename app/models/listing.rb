class Listing < ActiveRecord::Base
  attr_accessible :is_owner, :miles, :model_id, :phone, :price, :year, :zipcode, :post_date, :make_id, :title, :description

  belongs_to :zip, primary_key: :code, foreign_key: :zipcode

  belongs_to :make, class_name: "Subdivision", foreign_key: :make_id
  belongs_to :model, class_name: "Subdivision", foreign_key: :model_id

  has_many :thumbs, class_name: "Pic",
                    conditions: "pics.thumb_for IS NOT NULL"
  has_many :main_pics, class_name: "Pic",
                       conditions: "pics.thumb_for IS NULL"


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
                    includes(:thumbs, :make, :model, :zip).
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
    [self.year, self.make.name, self.model.name].compact.join(" ")
  end

end
