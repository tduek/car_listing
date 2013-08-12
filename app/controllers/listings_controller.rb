class ListingsController < ApplicationController
  def index
    params[:page] ||= 1
    @makes_array = Subdivision.where(level: 0).order(:name).
                               all.map { |make| [make.name, make.id] }
    @models_array = Subdivision.where(level: 1).order(:name).
                                all.map { |model| [model.name, model.id] }
    
    @listings = Listing.search(params[:search], params[:page])
    
    @sort_options = [["oldest first", "post_date_asc"], 
                     ["newest first", "post_date_desc"],
                     ["lowest price", "price_asc"], 
                     ["highest price", "price_desc"]]
                     
    params[:search] = {} unless params[:search]
    
    if request.xhr?
      sleep 3 if Rails.env.development?
      render @listings
    end
  end

  def show
    @listing = Listing.find(params[:id])
  end
end
