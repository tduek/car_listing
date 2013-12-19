class ApplicationController < ActionController::Base
  protect_from_forgery

  include UserSessionsHelper

  def raise_404
    raise ActiveRecord::RecordNotFound.new()
  end

end
