class Api::UsersController < ApiController

  def listings
    @listings = Listing.with_deal_ratio
                       .where(seller_id: params[:user_id])

    render partial: 'listings/listings.json'
  end

  def show
    @user = User.find(params[:id])

    render partial: 'users/user.json', locals: {user: @user}
  end

end