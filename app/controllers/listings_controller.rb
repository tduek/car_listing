class ListingsController < ApplicationController
  def index
    params[:page] ||= 1
    @makes_array = Subdivision.where(level: 0).order(:name).
                               all.map { |make| [make.name, make.id] }
    @models_array = Subdivision.where(level: 1).order(:name).
                                all.map { |model| [model.name, model.id] }
    
    @listings = Listing.search(params[:search], params[:page])
    
    @sort_options = [["Oldest first", "post_date_asc"], 
                     ["Newest first", "post_date_desc"],
                     ["Lowest price", "price_asc"], 
                     ["Highest price", "price_desc"]]
                     
    params[:search] = {} unless params[:search]
    
    if request.xhr?
      sleep 3
      render @listings
    end
  end

  def show
    @listing = Listing.find(params[:id])
  end
end
