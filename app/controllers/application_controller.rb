class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserSessionsHelper
  include ActiveSupport::Inflector

  helper_method :index_listings, :available_years, :search_params, :search_params_present?, :years_json, :subdivisions_json, :listings_json

  def valid_captcha?
    return false unless params[:recaptcha_challenge_field] && params[:recaptcha_response_field]

    url = 'http://www.google.com/recaptcha/api/verify'
    # Returns string => "true\nsuccess" or "false\nsol-incorrect"
    RestClient.post(url, {
      privatekey: ENV['RECAPTCHA_PRIVATE_KEY'],
      remoteip: request.remote_ip,
      challenge: params[:recaptcha_challenge_field],
      response: params[:recaptcha_response_field]
    }).starts_with?('true')
  end

  def set_singular_resource
    return @resource if @resource

    model_str = self.class.to_s.gsub("Controller", "").singularize
    model_class = model_str.constantize
    resource = model_class.find(params[:id])

    instance_variable_set("@#{model_str.downcase}", resource)
  end

  def singular_resource
    return @resource if @resource

    ivar = "@#{self.class.to_s.gsub("Controller", "").singularize.downcase}"
    @resource ||= instance_variable_get(ivar)

    @resource ? @resource : set_singular_resource
  end

  def raise_404
    raise ActiveRecord::RecordNotFound.new
  end


  def require_owner
    if singular_resource.user != current_user
      flash[:alert] = "You don't have access to that!"
      redirect_to request.referer || root_url
    end
  end

  def require_user_signed_in
    unless user_signed_in?
      session[:friendly_redirect] = request.env["REQUEST_URI"]
      redirect_to new_user_session_url, alert: "You must be signed in for that!"
    end
  end

  def search_params
    return @search_params if @search_params

    params[:search] ||= {}
    result = extract_search_params(params[:search])
    result = (result.empty? ? extract_search_params(params) : result)

    result.each do |k, v|
      result[k] = v.to_i unless Listing::STRING_SEARCH_PARAMS.include?(k.to_sym)
    end

    @search_params = result
  end

  def extract_search_params(indif_hash)
    indif_hash.select do |k, v|
      Listing::PERMITTED_SEARCH_KEYS.include?(k.to_sym) && v.present?
    end.with_indifferent_access
  end

  def search_params_present?
    !search_params.empty?
  end

  def years_json
    available_years.to_json.html_safe
  end

  def available_years
    return @available_yrs if @available_yrs

    @available_yrs = Year
      .select('years.year')
      .order('years.year DESC')
      .uniq
      .pluck(:year)
  end

  def subdivisions_json
    @makes = Subdivision
      .makes
      .order(:name)
      .includes(:active_models)

    render_to_string('subdivisions/index', formats: [:json]).html_safe
  end

  def listings_json
    @listings = index_listings

    render_to_string('api/listings/index', formats: [:json]).html_safe
  end

  def index_listings
    return @index_listings if @index_listings

    @index_listings = Listing
      .search(search_params, params[:page])
      .active
      .include_everything
  end


end
