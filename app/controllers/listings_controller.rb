class ListingsController < ApplicationController
  def index
    @listings = Listing.order("id DESC").page(params[:page])
  end

  def show
    @listing = Listing.find(params[:id])
  end
end
