class UsersController < ApplicationController

  def index
    @users = User.all
  end


  def show
    @user = User.find(params[:id])
  end


  def new
    @user = User.new
  end


  def create
    @user = User.new(params[:user])

    if @user.save
      UserMailer.activation_email(@user).deliver!
      @user.update_attribute(:activation_email_sent_at, Time.now)

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

    login_user!(@user)
    redirect_to @user
  end


  def resend_initial_activation_email
    @user = User.find(params[:id])
    UserMailer.initial_activation_email(@user).deliver!

    redirect_to @user, notice: "Almost done! Check your inbox for the activation email."
  end


  def change_email
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      UserMailer.change_email_verification_email(@user).deliver!
      notice = "Please verify your new email address. We sent an email to #{@user.email}"
    else
      notice = "Couldn't save the new email address: #{params[:user][:email]}. Please edit below."
    end

    redirect_to @user, notice: notice
  end

  def forgot_password
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
    @user.find(params[:id]).deactivate!
    flash[:success] = "Account deactivated.. :("
    redirect_to root_url
  end
end
