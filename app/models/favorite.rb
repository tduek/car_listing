class Favorite < ActiveRecord::Base
  attr_accessible :listing_id, :user_id

  belongs_to :listing
  belongs_to :user

  validates :listing_id, uniqueness: {scope: :user_id}

end
