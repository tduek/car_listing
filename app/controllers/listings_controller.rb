class ListingsController < ApplicationController
  def index
    @listings = Listing.order("id DESC").page(params[:page])
  end

  def show
  end
end
