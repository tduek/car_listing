class ListingsController < ApplicationController
  before_filter :require_user_signed_in, only: [:new, :create, :edit, :update, :destroy, :favorites]
  before_filter :require_owner, only: [:edit, :update, :destroy]

  PERMITTED_SEARCH_KEYS = [
    :year_from, :year_to,
    :make_id, :model_id,
    :price_from, :price_to,
    :zip, :dist,
    :sort
  ]

  STRING_SEARCH_PARAMS = [:sort]

  def index
    params[:search] ||= {}
    params[:page] ||= 1
    @search_params = search_params
    @listings = Listing.search(@search_params, params[:page])
                       .preload(:pics, :main_pic, :make, :model, :zip, {seller: :zip})

    @page_data = extract_page_data(@listings)
    if request.xhr?
      #sleep 1 if Rails.env.development?
      render(partial: 'listings/index_listings.json') && return
    end

    @makes = Subdivision.makes.includes(:active_models).order(:name)
    @years = Year.select('years.year').order('years.year').uniq.map(&:year)

    zip = params[:search][:zip]
    if zip && zip.length > 1 && !Zip.find_by_code(zip)
      flash[:alert] = "Invalid zipcode. Please check your input."
    end
  end

  def favorites
    @listings = current_user.favorited_listings.includes(
      :make, :model, :pics, :main_pic, :zip
    )

    render partial: 'listings/listings.json'
  end

  def show
    @listing = Listing.includes(:make, :model, :pics, :main_pic).find(params[:id])
    @title = "#{@listing.ymm} | "

    if request.xhr?
      render partial: 'listings/listing.json', locals: {listing: @listing}
    end
  end

  def new
    @listing = current_user.listings.new
  end


  def create
    params[:listing][:phone].gsub!(/\D/, '') if params[:listing][:phone]
    @listing = current_user.listings.new(params[:listing])

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
    result = (result.empty? ? extract_search_params(params) : result)

    result.each do |k, v|
      result[k] = v.to_i unless STRING_SEARCH_PARAMS.include?(k.to_sym)
    end

    result
  end

  def extract_search_params(indif_hash)
    indif_hash.select do |k, v|
      PERMITTED_SEARCH_KEYS.include?(k.to_sym) && v.present?
    end.with_indifferent_access
  end

  def extract_page_data(listings)
    cheap_count = listings.cheap_total_count
    {
      # total_count: (listings.respond_to?(:total_count) ? listings.total_count : Listing.cached_count),
      total_count: cheap_count,
      total_pages: cheap_count / 25,
      current_page: (listings.respond_to?(:current_page) ? listings.current_page : params[:page].to_i)
    }
  end

end
