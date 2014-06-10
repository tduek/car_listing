class FavoritesController < ApplicationController

  def create
    favorite = current_user
                  .favorites
                  .find_or_create_by_listing_id(listing_id: params[:listing_id])

    if request.xhr?
      head :ok
    else
      flash[:success] = <<-HTML
        Favorited the #{ link_to(listing.ymm, listing) }.
      HTML
      redirect_to current_user
    end
  end


  def destroy
    current_user.favorites.find_by_listing_id!(params[:listing_id])

    if request.xhr?
      head :ok
    else
      flash[:success] = <<-HTML
        Unfavorited the #{ link_to(listing.ymm, listing) }."
      HTML
      redirect_to current_user
    end
  end
end
