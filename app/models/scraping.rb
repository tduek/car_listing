class Scraping < ActiveRecord::Base
  attr_accessible :craigs_site_id, :description, :guid, :parsed, :post_date, :seller_type, :source, :title, :url, :dqed, :price
  
  belongs_to :craigs_site
  
  has_many :thumbs, -> { where type: PIC_TYPES[:thumb] }
  has_many :main_pics, -> { where type: PIC_TYPES[:main_pic] }
  
  extend CraigslistCarScraper
  extend CLCarsParse
end
