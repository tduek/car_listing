class ListingsController < ApplicationController
  before_filter :require_user_signed_in, only: [:new, :create, :edit, :update, :destroy]
  before_filter :require_owner, only: [:edit, :update, :destroy]

  PERMITTED_SEARCH_KEYS = [
    :year_from, :year_to,
    :make_id, :model_id,
    :price_from, :price_to,
    :zip, :dist,
    :sort
  ]

  def index
    params[:search] ||= {}
    params[:page] ||= 1
    @search_params = search_params
    @listings = Listing.search(@search_params, params[:page])

    if request.xhr?
      #sleep 1 if Rails.env.development?
      render(partial: 'listings/index.json') && return
    end

    @makes = Subdivision.makes.includes(:active_models).order(:name)
    @years = Year.select('years.year').order('years.year').uniq.map(&:year)

    params[:search].each { |k, v| @search_params[k] = v.to_i }

    @sort_options = [["oldest first", "post_date_asc"],
                     ["newest first", "post_date_desc"],
                     ["lowest price", "price_asc"],
                     ["highest price", "price_desc"],
                     ["distance", "distance"]]

    zip = params[:search][:zip]
    if zip && zip.length > 1 && !Zip.find_by_code(zip)
      flash[:alert] = "Invalid zipcode. Please check your input."
    end
  end

  def show
    @listing = Listing.includes(:make, :model, :pics, :main_pic).find(params[:id])
    @title = "#{@listing.ymm} | "
  end

  def new
    @listing = current_user.listings.new
  end


  def create
    params[:listing][:phone].gsub!(/\D/, '') if params[:listing][:phone]
    @listing = current_user.listings.new(params[:listing])
    @listing.zipcode = current_user.zip
    @listing.is_owner = !current_user.is_dealer
    @listing.post_date = Time.now

    params[:pics] && params[:pics].values.each_with_index do |pic_params, i|
      next unless pic_params[:file] || pic_params[:token].length > 0

      pic_params.merge!({ord: i + 1})

      if pic_params[:file]
        @listing.pics.new(pic_params)
      elsif !pic_params[:token].empty?
        pic = Pic.find_by_token(pic_params[:token])
        pic.ord = i + 1
        @listing.pics << pic
      end

    end

    if @listing.save
      @listing.pics.update_all(token: nil)
      flash[:success] = "Successfully listed your #{@listing.ymm}"
      redirect_to @listing
    else
      flash.now[:alert] = "Couldn't save your listing. Check below."
      render :new
    end
  end


  def edit
    @listing = Listing.find(params[:id])
  end


  def update
    @listing = Listing.find(params[:id])

    if @listing.update_attributes(params[:listing])
      flash[:success] = "Successfully saved changes to your #{@listing.ymm}"
      redirect_to @listing
    else
      flash.now[:alert] = "Couldn't save changes to your #{@liasting.name || 'listing'}. Check below."
      render :edit
    end
  end

  def destroy
    @listing = Listing.find(params[:id])

    @listing.destroy

    flash[:succes] = "Successfully removed your #{@listing.ymm} from our listings."
    redirect_to current_user
  end

  private

  def search_params
    result = extract_search_params(params[:search])

    result.empty? ? extract_search_params(params) : result
  end

  def extract_search_params(indif_hash)
    params.select do |k, v|
      PERMITTED_SEARCH_KEYS.include?(k.to_sym) && v.present?
    end.with_indifferent_access
  end

end
