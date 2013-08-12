class Listing < ActiveRecord::Base
  attr_accessible :is_owner, :miles, :model_id, :phone, :price, :scraping_id, :year, :zipcode, :post_date
  
  belongs_to :scraping
  belongs_to :zip, primary_key: :code, foreign_key: :zipcode
  
  belongs_to :make, class_name: "Subdivision", foreign_key: :make_id
  belongs_to :model, class_name: "Subdivision", foreign_key: :model_id
  
  has_many :thumbs, class_name: "Pic", 
                    conditions: "pics.thumb_for IS NOT NULL"
  has_many :main_pics, class_name: "Pic",
                       conditions: "pics.thumb_for IS NULL"

     
#   Listing.select('listings.*, acos(cos(radians(25.95))*cos(radians(-80.14))*cos(radians("zips"."lat"))*cos(radians("zips"."long")) + cos(radians(25.95))*sin(radians(-80.14))*cos(radians("zips"."lat"))*sin(radians("zips"."long")) + sin(radians(25.95))*sin(radians("zips"."lat"))) * 3982*1.17 AS distance').where('acos(cos(radians(25.95))*cos(radians(-80.14))*cos(radians("zips"."lat"))*cos(radians("zips"."long")) + cos(radians(25.95))*sin(radians(-80.14))*cos(radians("zips"."lat"))*sin(radians("zips"."long")) + sin(radians(25.95))*sin(radians("zips"."lat"))) * 3982*1.17 < 300').joins(:zip)
# #   
#   
#Works, returns all zips and their distance to zip supplied in #where at end
   Zip.select('zips2.*, acos(cos(radians("zips1"."lat"))*cos(radians("zips1"."long"))*cos(radians("zips2"."lat"))*cos(radians("zips2"."long")) + cos(radians("zips1"."lat"))*sin(radians("zips1"."long"))*cos(radians("zips2"."lat"))*sin(radians("zips2"."long")) + sin(radians("zips1"."lat"))*sin(radians("zips2"."lat"))) * 3982*1.17 AS distance').from('"zips" AS "zips1" CROSS JOIN "zips" AS "zips2"').where('"zips1"."code"=?', '33180').where(distance: 0..100)
#   
Zip.find_by_sql(['SELECT zips_with_dist.* FROM (SELECT zips2.*, acos(cos(radians("zips1"."lat"))*cos(radians("zips1"."long"))*cos(radians("zips2"."lat"))*cos(radians("zips2"."long")) + cos(radians("zips1"."lat"))*sin(radians("zips1"."long"))*cos(radians("zips2"."lat"))*sin(radians("zips2"."long")) + sin(radians("zips1"."lat"))*sin(radians("zips2"."lat"))) * 3982*1.17 AS distance FROM "zips" AS "zips1" CROSS JOIN "zips" AS "zips2" WHERE "zips1"."code"=?) AS "zips_with_dist" WHERE "zips_with_dist"."distance" <= ?', '33180', '50')
#   
Zip.select("zips_with_dist.*").from('(SELECT zips2.*, acos(cos(radians("zips1"."lat"))*cos(radians("zips1"."long"))*cos(radians("zips2"."lat"))*cos(radians("zips2"."long")) + cos(radians("zips1"."lat"))*sin(radians("zips1"."long"))*cos(radians("zips2"."lat"))*sin(radians("zips2"."long")) + sin(radians("zips1"."lat"))*sin(radians("zips2"."lat"))) * 3982*1.17 AS distance FROM "zips" AS "zips1" CROSS JOIN "zips" AS "zips2" WHERE "zips1"."code"=?) AS "zips_with_dist"').bind('"zips1"."code"' => '33180').where('"zips_with_dist"."distance"<=?').bind('"zips_with_dist"."distance"' => '50')
#   
#     Zip.from(Listing.zips_with_distance('33180')).where(['"distance"<? OR "code"=?', '50', '33180')
    
      def self.zips_with_distance(zip, radius)
        Zip.select('zips2.*, acos(cos(radians("zips1"."lat"))*cos(radians("zips1"."long"))*cos(radians("zips2"."lat"))*cos(radians("zips2"."long")) + cos(radians("zips1"."lat"))*sin(radians("zips1"."long"))*cos(radians("zips2"."lat"))*sin(radians("zips2"."long")) + sin(radians("zips1"."lat"))*sin(radians("zips2"."lat"))) * 3982*1.17 AS distance').
            from('"zips" AS "zips1" CROSS JOIN "zips" AS "zips2"').
            where(['"zips1"."code"=? OR acos(cos(radians("zips1"."lat"))*cos(radians("zips1"."long"))*cos(radians("zips2"."lat"))*cos(radians("zips2"."long")) + cos(radians("zips1"."lat"))*sin(radians("zips1"."long"))*cos(radians("zips2"."lat"))*sin(radians("zips2"."long")) + sin(radians("zips1"."lat"))*sin(radians("zips2"."lat"))) * 3982*1.17 <= ?', zip, radius])
      end
    
  Listing.select('"listings"."*", "zip"."distance"').joins('INNER JOIN (SELECT zips_with_dist.* FROM (SELECT zips2.*, acos(cos(radians("zips1"."lat"))*cos(radians("zips1"."long"))*cos(radians("zips2"."lat"))*cos(radians("zips2"."long")) + cos(radians("zips1"."lat"))*sin(radians("zips1"."long"))*cos(radians("zips2"."lat"))*sin(radians("zips2"."long")) + sin(radians("zips1"."lat"))*sin(radians("zips2"."lat"))) * 3982*1.17 AS distance FROM "zips" AS "zips1" CROSS JOIN "zips" AS "zips2" WHERE ("zips1"."code"=33180)) AS "zips_with_dist" WHERE "zip"."distance"<50) AS "zip" ON "listings"."zipcode"="zip"."code"')
  
  
  def self.search(terms, page)
    results = Listing.where("listings.model_id IS NOT NULL").
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
      
      case terms[:sort]
      when "post_date_asc"
        results = results.order(:post_date)
      when "post_date_desc"
        results = results.order("listings.post_date DESC")
      when "price_asc"
        results = results.order(:price)
      when "price_desc"
        results = results.order("listings.price DESC")
      else
        results = results.order("listings.id DESC")
      end
    end
    
    results.order("listings.post_date DESC")
  end
end
