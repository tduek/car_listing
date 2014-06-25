class PhonesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def show
    sleep 1
    if valid_captcha?
      listing = Listing.find(params[:listing_id])
      phone = number_to_phone(listing.phone)
      render json: {phone: phone}
    else
      head 401
    end
  end
end
