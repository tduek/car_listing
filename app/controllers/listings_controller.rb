class ListingsController < ApplicationController
  def index
    params[:search] = {} unless params[:search]
    params[:page] ||= 1
    @makes_array = Subdivision.where(level: 0).order(:name).
                               all.map { |make| [make.name, make.id] }
    @models_array = Subdivision.where(level: 1).order(:name).
                                all.map { |model| [model.name, model.id] }
    
    @listings = Listing.search(params[:search], params[:page])
    
    @sort_options = [["oldest first", "post_date_asc"], 
                     ["newest first", "post_date_desc"],
                     ["lowest price", "price_asc"], 
                     ["highest price", "price_desc"],
                     ["distance", "distance"]]
                     
    zip = params[:search][:zip]
    if zip && zip.length > 1 && !Zip.find_by_code(zip)
      flash[:alert] = "Invalid zipcode. Please check your input."
    end
    
    if request.xhr?
      #sleep 1 if Rails.env.development?
      render @listings
    end
  end

  def show
    @listing = Listing.find(params[:id])
  end
end
