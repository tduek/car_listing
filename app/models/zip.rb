class Zip < ActiveRecord::Base
  attr_accessible :city, :code, :lat, :long, :st, :state

  has_many :listings, primary_key: :code, foreign_key: :zipcode

  def self.state_abbreviations
    select(:st).order(:st).uniq.map(&:st)
  end

  def self.near(distance, zip)
    Zip.select("zips_with_distance.*").
        from("(#{zips_with_distance_from(zip).to_sql}) AS \"zips_with_distance\"").
        where(['"zips_with_distance"."distance" <= ? OR "zips_with_distance"."code" = ?', distance, zip]).
        order('"zips_with_distance"."distance"')
  end


  # FIX THIS BIND IN THE SELECT!!!
  def self.zips_with_distance_from(zip)
    Zip.select("zips2.*, CASE \"zips2\".\"code\"
                         WHEN '#{zip}' THEN 0
                         ELSE acos(
                                cos(radians(\"zips1\".\"lat\")) *
                                cos(radians(\"zips1\".\"long\"))*
                                cos(radians(\"zips2\".\"lat\")) *
                                cos(radians(\"zips2\".\"long\"))+
                                cos(radians(\"zips1\".\"lat\")) *
                                sin(radians(\"zips1\".\"long\"))*
                                cos(radians(\"zips2\".\"lat\")) *
                                sin(radians(\"zips2\".\"long\"))+
                                sin(radians(\"zips1\".\"lat\")) *
                                sin(radians(\"zips2\".\"lat\")))*
                              3982 * 1.17
                         END AS distance").
        from('"zips" AS "zips1" CROSS JOIN "zips" AS "zips2"').
        where('"zips1"."code"=?', zip)
  end


  # CASE "zips2"."code"
  # WHEN ? THEN 0
  # ELSE acos(
  #           cos(radians("zips1"."lat")) *
  #           cos(radians("zips1"."long"))*
  #           cos(radians("zips2"."lat")) *
  #           cos(radians("zips2"."long"))+
  #           cos(radians("zips1"."lat")) *
  #           sin(radians("zips1"."long"))*
  #           cos(radians("zips2"."lat")) *
  #           sin(radians("zips2"."long"))+
  #           sin(radians("zips1"."lat")) *
  #           sin(radians("zips2"."lat")))*
  #       3982 * 1.17
  # END
  # AS distance

end
