class Pic < ActiveRecord::Base
  attr_accessible :listing_id, :thumb_for, :is_thumb, :file

  has_attached_file :file, styles: {sthumb: "50x50!", lthumb: "100x100!", full_size: "650"}

  belongs_to :listing
end
