class Pic < ActiveRecord::Base
  attr_accessible :listing_id, :scraping_id, :src, :thumb_for, :is_thumb
  
  belongs_to :listing
  belongs_to :scraping
  
  belongs_to :main_pic, class_name: "Pic", foreign_key: :thumb_for
  has_one :thumb, class_name: "Pic", foreign_key: :thumb_for
end
