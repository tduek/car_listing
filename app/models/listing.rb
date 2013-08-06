class Listing < ActiveRecord::Base
  attr_accessible :is_owner, :miles, :model_id, :phone, :price, :scraping_id, :year, :zip
end
