class Zip < ActiveRecord::Base
  attr_accessible :city, :code, :lat, :long, :st, :state
  
  has_many :listings, primary_key: :code, foreign_key: :zipcode
  
  
  def self.near(distance, zip)
    Zip.select("zips_with_distance.*").
        from("(#{zips_with_distance_from(zip).to_sql}) AS \"zips_with_distance\"").
        where(['"zips_with_distance"."distance" <= ? OR "zips_with_distance"."code" = ?', distance, zip]).
        order('"zips_with_distance"."distance"')
  end

  def self.zips_with_distance_from(zip)
    Zip.select('zips2.*, acos(cos(radians("zips1"."lat")) *
                              cos(radians("zips1"."long"))*
                              cos(radians("zips2"."lat")) *
                              cos(radians("zips2"."long"))+ 
                              cos(radians("zips1"."lat")) *
                              sin(radians("zips1"."long"))*
                              cos(radians("zips2"."lat")) *
                              sin(radians("zips2"."long"))+ 
                              sin(radians("zips1"."lat")) *
                              sin(radians("zips2"."lat")))* 
                         3982 * 1.17 AS distance').
        from('"zips" AS "zips1" CROSS JOIN "zips" AS "zips2"').
        where('"zips1"."code"=?', zip)
  end
  
  
  
  
  
  
  
  
  # def self.near(zip, radius)
  #   Zip.find_by_sql(['SELECT zips_with_dist.* 
  #                     FROM (SELECT zips2.*, acos(cos(radians("zips1"."lat"))  *
  #                                                cos(radians("zips1"."long")) *
  #                                                cos(radians("zips2"."lat"))  *
  #                                                cos(radians("zips2"."long")) + 
  #                                                cos(radians("zips1"."lat"))  *
  #                                                sin(radians("zips1"."long")) *
  #                                                cos(radians("zips2"."lat"))  *
  #                                                sin(radians("zips2"."long")) + 
  #                                                sin(radians("zips1"."lat"))  *
  #                                                sin(radians("zips2"."lat"))) 
  #                                            * 3982 * 1.17 AS distance 
  #                            FROM "zips" AS "zips1" 
  #                            CROSS JOIN "zips" AS "zips2" 
  #                            WHERE "zips1"."code"=?) 
  #                       AS "zips_with_dist" 
  #                       WHERE "zips_with_dist"."distance" <= ? 
  #                       OR "zips_with_dist"."code"=?', zip, radius, zip])
  # end 
  #Zip.select('zips_with_dist.*').from('(SELECT zips2.*, acos(cos(radians("zips1"."lat"))*cos(radians("zips1"."long"))*cos(radians("zips2"."lat"))*cos(radians("zips2"."long")) + cos(radians("zips1"."lat"))*sin(radians("zips1"."long"))*cos(radians("zips2"."lat"))*sin(radians("zips2"."long")) + sin(radians("zips1"."lat"))*sin(radians("zips2"."lat"))) * 3982*1.17 AS distance FROM "zips" AS "zips1" CROSS JOIN "zips" AS "zips2" WHERE "zips1"."code"=?) AS "zips_with_dist"').bind(["code", '33180']).where('"zips_with_dist"."distance" <= ?', '50')
end
