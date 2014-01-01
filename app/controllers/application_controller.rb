class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserSessionsHelper
  include ActiveSupport::Inflector

  def set_singular_resource
    model_str = self.class.to_s.gsub("Controller", "").singularize
    model_class = model_str.constantize
    resource = model_class.find(params[:id])

    instance_variable_set("@#{model_str.downcase}", resource)
  end

  def singular_resource
    return @resource if @resource
    ivar = "@#{self.class.to_s.gsub("Controller", "").singularize.downcase}"
    @resource ||= instance_variable_get(ivar)
  end

  def raise_404
    raise ActiveRecord::RecordNotFound.new()
  end


  def require_owner
    if user_logged_in? && current_user == singular_resource.user
      # Do nothing.
    elsif user_logged_in? && current_user != singular_resource.user
      redirect_to :back, alert: "You don't have access to that!"
    elsif !user_logged_in?
      redirect_to new_user_session_url, alert: "You must be logged in for that!"
    end
  end

end
