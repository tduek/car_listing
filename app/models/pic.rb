class Pic < ActiveRecord::Base
  attr_accessible :listing_id, :thumb_for, :is_thumb, :file, :ord

  MAX_SIZE = 4.megabytes
  ACCEPTED_TYPES = %w(jpeg jpg png bmp)

  has_attached_file :file
  validates_attachment :file,
    presence: true,
    content_type: {
      content_type: /\Aimage\/(#{ACCEPTED_TYPES.join('|')})\Z/,
      message: "must be a .jpeg, .jpg, or .bmp image"
    },
    size: {
      less_than: MAX_SIZE,
      message: "must be under #{ MAX_SIZE / 1.megabyte }Mb"
    }

  belongs_to :listing

  before_create :generate_token_unless_listing

  def generate_token_unless_listing
    unless self.listing_id || self.listing
      self.token = generate_unique_token_for_field(:token)
    end
  end

  def as_json(options = {})
    {
      id: self.id,
      listing_id: self.listing_id,
      ord: self.ord,
      url: self.file.url
    }
  end

end
