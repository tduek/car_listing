class FavoritesController < ApplicationController
  before_filter :require_user_signed_in

  def create
    favorite = current_user
                  .favorites
                  .find_or_create_by_listing_id(listing_id: params[:listing_id])

    render json: favorite
  end


  def destroy
    current_user.favorites.find_by_listing_id!(params[:listing_id]).destroy

    render json: {hack: 'because $.ajax needs responseText to call success.'}
  end
end
