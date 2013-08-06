class Subdivision < ActiveRecord::Base
  attr_accessible :name, :parent_id, :level
  
  has_many :children, class_name: "Subdivision", foreign_key: :parent_id
  
  belongs_to :parent, class_name: "Subdivision", foreign_key: :parent_id
  
  has_many :spellings
end
