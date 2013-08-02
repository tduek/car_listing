class Scraping < ActiveRecord::Base
  attr_accessible :craigs_site_id, :description, :guid, :parsed, :post_date, :seller_type, :source, :title, :url
  
  belongs_to :craigs_site
  
  extend CraigslistScrape
end
