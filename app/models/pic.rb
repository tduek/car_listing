class Pic < ActiveRecord::Base
  attr_accessible :listing_id, :thumb_for, :is_thumb, :file, :ord, :src

  has_attached_file :file
  validates_attachment :file, presence:     true,
                              content_type: {content_type: /\Aimage\/(jpeg|jpg|png|bmp)\Z/, message: "must be a .jpeg, .jpg, or .bmp image"},
                              size:         {less_than: 1.megabytes, message: "must be under 5 Mb"}

  belongs_to :listing

  before_create :generate_token_unless_listing

  def generate_token_unless_listing
    unless self.listing_id || self.listing
      self.token = generate_unique_token_for_field(:token)
    end
  end

end
