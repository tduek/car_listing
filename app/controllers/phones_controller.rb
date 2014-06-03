class PhonesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def show
    if valid_captcha?
      listing = Listing.find(params[:listing_id])
      phone = number_to_phone(listing.phone)
      render json: {phone: phone}
    else
      render json: {phone: false}
    end
  end
end
