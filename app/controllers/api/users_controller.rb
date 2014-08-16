class Api::UsersController < Api::ApiController

  def listings
    @listings = Listing
      .with_deal_ratio
      .include_everything
      .where(seller_id: params[:id])
      .active
  end

  def show
    @user = User.find(params[:id])
  end

end