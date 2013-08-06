class Spelling < ActiveRecord::Base
  attr_accessible :string, :subdivision_id
  
  belongs_to :subdivision
end
