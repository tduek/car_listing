class CraigsSite < ActiveRecord::Base
  attr_accessible :city, :city_for_url, :latitude, :longitude, :zip
  
  has_many :scrapings
end
