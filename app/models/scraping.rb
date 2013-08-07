class Scraping < ActiveRecord::Base
  attr_accessible :craigs_site_id, :description, :guid, :parsed, :post_date, :seller_type, :source, :title, :url, :dqed, :price
  
  belongs_to :craigs_site
  
  has_many :thumbs, class_name: "Pic", 
                    conditions: "pics.thumb_for IS NOT NULL"
  has_many :main_pics, class_name: "Pic",
                       conditions: "pics.thumb_for IS NULL"
  
  extend CraigslistCarScraper
  extend CLCarsParse
end
