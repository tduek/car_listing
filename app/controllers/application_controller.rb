class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserSessionsHelper
  include ActiveSupport::Inflector

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
    raise ActiveRecord::RecordNotFound.new()
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

end
