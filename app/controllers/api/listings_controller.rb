class Api::ListingsController < ApiController

  def index
    @listings = Listing.search(search_params, params[:page])
                       .preload(:pics, :main_pic, :make, :model, :zip, {seller: :zip})
  end

  def favorites
    @listings = current_user.favorited_listings.includes(
      :make, :model, :pics, :main_pic, :zip
    )
  end

end