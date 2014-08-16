class ListingsController < ApplicationController
  before_filter :require_user_signed_in, only: [:new, :create, :edit, :update, :destroy]
  before_filter :require_owner, only: [:edit, :update, :destroy]

  def index
    # rendering a partial in 'index.html.erb' with formats: [:json],
    # which sets the response to Content-Type="application/json"
    # and looks for .json templates and layout, so overwrote
    # content-type and hard-coded extension and templating engine.
    render 'index.html.erb', content_type: 'text/html', layout: 'application.html.erb'
  end

  def show
    @listing = Listing.find(params[:id])

    if @listing.is_active? || @listing.seller == current_user
      # rendering a partial in :show with formats: [:json],
      # which sets the response to Content-Type="application/json"
      # and looks for .json templates and layout, so overwrote
      # content-type and hard-coded extension and templating engine.
      render :show, content_type: 'text/html', layout: 'application.html.erb'
    else
      raise_404
    end
  end

  def new
    @listing = current_user.listings.new

    # rendering a partial in :new with formats: [:json],
    # which sets the response to Content-Type="application/json"
    # and looks for .json templates and layout, so overwrote
    # content-type and hard-coded extension and templating engine.
    render :new, content_type: 'text/html', layout: 'application.html.erb'
  end


  def create
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
      render :new, content_type: 'text/html', layout: 'application.html.erb'
    end
  end


  def edit
    @listing = Listing.find(params[:id])
  end


  def update
    @listing = Listing.find(params[:id])
    old_pics = @listing.pics.to_a

    new_tokens = []
    new_files = []
    params[:pics].values.each do |pic_params|
      new_tokens << pic_params[:token] && next if pic_params[:token].present?
      new_files << pic_params[:file] if pic_params[:file].present?
    end

    new_files.map! { |file| Pic.new(file: file) }
    new_pics = Pic.where(token: new_tokens).to_a + new_files
    new_pics.each_with_index { |pic, i| pic.ord = i + 1 }

    pic_ids_to_rm = old_pics.map(&:id) - new_pics.map(&:id)
    pics_to_rm = Pic.where(id: pic_ids_to_rm)

    params[:listing][:pics] = new_pics

    begin
      ActiveRecord::Base.transaction do
        pics_to_rm.each(&:destroy)
        @listing.update_attributes(params[:listing])

        if pics_to_rm.any?(&:persisted?) || !@listing.update_attributes(params[:listing])
          raise ActiveRecord::RecordNotSaved
        end
      end

      flash[:success] = "Successfully saved changes to your #{@listing.ymm}"
      redirect_to @listing
    rescue ActiveRecord::RecordNotSaved
      flash.now[:alert] = "Couldn't save changes to your #{@listing.name || 'listing'}. Check below."
      render :edit, content_type: 'text/html', layout: 'application.html.erb'
    end
  end

  def destroy
    @listing = Listing.find(params[:id])
    @listing.deactivate!

    flash[:success] = "Removed your #{ @listing.ymm } from our listings."
    redirect_to dashboard_url
  end


end
