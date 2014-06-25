module UsersHelper

  def favorited_listing_ids
    @favorite_listing_ids ||= (current_user.try(:favorited_listing_ids) || [])
  end

end
