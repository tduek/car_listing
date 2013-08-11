class Zip < ActiveRecord::Base
  attr_accessible :city, :code, :lat, :long, :st, :state
  
  has_many :listings, primary_key: :code, foreign_key: :zip
end
