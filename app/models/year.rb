class Year < ActiveRecord::Base
  attr_accessible :model_id, :year

  belongs_to :model, class_name: 'Subdivision'
  has_many :listings, through: :model, source: :model_listings

end
