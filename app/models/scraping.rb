class Scraping < ActiveRecord::Base
  attr_accessible :craigs_site_id, :description, :guid, :parsed, :post_date, :seller_type, :source, :title, :url, :dqed, :price
  
  belongs_to :craigs_site
  
  has_many :thumbs, class_name: "Pic", 
                    conditions: "is_thumb = true"
  has_many :main_pics, class_name: "Pic",
                       conditions: "is_thumb = false"
  
  extend CraigslistCarScraper
  extend CLCarsParse
end
