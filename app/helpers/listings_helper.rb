module ListingsHelper

  def is_favorite?(listing)
    favorited_listing_ids.include?(listing.id)
  end

end
