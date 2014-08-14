class ForgotUserPasswordsController < ApplicationController
  # Step 1: Lost password form.
  def new
  end

  # Step 2: Submit for step 1, sends email.
  def create
    @user = User.find_by_email(params[:email])

    if @user
      UserMailer.forgot_password_email(@user).deliver!

      flash[:success] = "Check your email for a link to reset your password. The link expires in 30 minutes."
      redirect_to root_url
    else
      flash.now[:alert] = "We don't have anyone under \"#{params[:email]}\""
      render :new
    end
  end

  # Step 3: Link on email. Has form for new password.
  def reset_password
    @user = User.find_by_forgot_password_token(params[:forgot_password_token])
    raise_404 unless good_password_change_request?

    @user.reset_password!
  end

  # Step 4: Submit of new password.
  def update
    @user = User.find_by_forgot_password_token(params[:forgot_password_token])
    raise_404 unless good_password_change_request?

    @user.password_required!
    if  @user.update_attributes(password_params)
      signin_user!(@user)
      flash[:success] = "Changed password successfully!"
      redirect_to dashboard_url
    else
      flash.now[:alert] = "Couldn't change password. See below."
      render :reset_password
    end
  end

  private
  def good_password_change_request?
    @user &&
    params[:forgot_password_token] &&
    @user.forgot_password_email_sent_at > 30.minutes.ago
  end

  def password_params
    {
      password: params[:password][:new_password],
      password_confirmation: params[:password][:password_confirmation]
    }
  end

end
