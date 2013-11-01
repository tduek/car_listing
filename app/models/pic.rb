class Pic < ActiveRecord::Base
  attr_accessible :listing_id, :thumb_for, :is_thumb, :file

  has_attached_file :file

  belongs_to :listing

  belongs_to :main_pic, class_name: "Pic", foreign_key: :thumb_for
  has_one :thumb, class_name: "Pic", foreign_key: :thumb_for
end
