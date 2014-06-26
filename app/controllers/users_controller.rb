class UsersController < ApplicationController
  before_filter :set_singular_resource, only:
    [:show, :edit, :update, :destroy, :resend_initial_activation_email, :change_email]

  before_filter :require_owner, only:
    [:show, :edit, :update, :destroy, :resend_initial_activation_email, :change_email]


  def listings
    @listings = Listing.where(user_id: params[:user_id])

    render partial: 'listings/listings.json'
  end


  def index
    @users = User.all
  end


  def show
    @user = User.find(params[:id])

    if request.xhr?
      render partial: 'users/user.json', locals: {user: @user}
    end
  end


  def new
    @user = User.new
  end


  def create
    @user = User.new(params[:user])

    if @user.save
      UserMailer.initial_activation_email(@user).deliver!
      @user.update_attribute(:activation_email_sent_at, Time.now)

      signin_user!(@user)
      redirect_to @user, notice: "Almost done! Check your inbox for the activation email."
    else
      flash[:alert] = "Something went terribly wrong. Check below."
      render :new
    end
  end


  def activate
    @user = User.find_by_activation_token(params[:activation_token])
    raise_404 unless @user

    if @user.is_activated?
      flash[:notice] = "Already activated, now enjoy."
    else
      @user.activate!
      flash[:notice] = "Activated your account successfully! Enjoy!"
    end

    signin_user!(@user)
    redirect_to @user
  end


  def resend_initial_activation_email
    @user = User.find(params[:id])
    UserMailer.initial_activation_email(@user).deliver!

    redirect_to @user, notice: "Almost done! Check your inbox for the activation email."
  end



  def reset_password
    @user = User.find_by_email(params[:email])

    if @user
      UserMailer.reset_password_email(@user).deliver!

      flash[:success] = "Successfully reset your password. Please check your email inbox to set a new one."
      redirect_to @user
    else
      flash.now[:bad_email] = "We don't have any accounts for #{params[:email]}"
      render :forgot_password
    end
  end


  def edit
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])

    if params[:user][:email] != @user.email
      UserMailer.change_email_verification_email(@user).deliver!
      @changed_email = true
    end

    if @user.update_attributes(params[:user])
      flash[:success] = "Saved changes! #{"Please check your inbox to verify your new email address." if @changed_email}"
      redirect_to @user
    else
      msg = "Couldn't save changes. Check below."

      if request.referrer["edit"]
        flash.now[:alert] = msg
        render :edit
      else
        redirect_to :back, alert: msg
      end
    end
  end


  def destroy
    @user.deactivate!
    flash[:success] = "Account deactivated.. :("
    redirect_to root_url
  end

end
