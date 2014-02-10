class Pic < ActiveRecord::Base
  attr_accessible :listing_id, :thumb_for, :is_thumb, :file, :ord, :src

  has_attached_file :file

  belongs_to :listing
end
