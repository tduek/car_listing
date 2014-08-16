class Api::ListingsController < Api::ApiController

  def index
    @listings = Listing
      .search(search_params, params[:page])
      .preload(:pics, :main_pic, :make, :model, :zip, {seller: :zip})
      .active
  end

  def show
    @listing = Listing.find(params[:id])

    unless @listing.is_active? || @listing.seller == current_user
      raise_404
    end
  end

  def favorites
    @listings = current_user.favorited_listings.includes(
      :make, :model, :pics, :main_pic, :zip
    )
  end



end