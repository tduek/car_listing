class Listing < ActiveRecord::Base
  attr_accessible :is_owner, :miles, :model_id, :phone, :price, :scraping_id, :year, :zip
  
  belongs_to :scraping
  
  belongs_to :make, class_name: "Subdivision", foreign_key: :make_id
  belongs_to :model, class_name: "Subdivision", foreign_key: :model_id
  
  has_many :thumbs, class_name: "Pic", 
                    conditions: "is_thumb = true"
  has_many :main_pics, class_name: "Pic",
                       conditions: "is_thumb = false"
end
