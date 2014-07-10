class Api::ContactInfosController < ApiController
  include ActionView::Helpers::NumberHelper

  def show
    sleep 1
    if valid_captcha?
      user = User.find(params[:user_id])
      phone = number_to_phone(user.phone)
      render json: {phone: phone}
    else
      head 401
    end
  end
end
