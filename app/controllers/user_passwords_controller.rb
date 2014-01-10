class UserPasswordsController < ApplicationController
  # Step 1: Lost password form.
  def edit
  end

  # Step 2: Submit for step 1, sends email.
  def update
    @user = User.find_by_email(params[:email])

    if @user
      UserMailer.reset_password_email(@user).deliver!

      flash[:success] = "Please check your email inbox for a link to reset your password."
      redirect_to @user
    else
      flash.now[:bad_email] = "We don't have any accounts for #{params[:email]}"
      render :forgot_password
    end
  end

  # Step 3: Link on email. Has form for new password.
  def new
    @user = User.find_by_reset_password_token(params[:reset_password_token])
    raise_404 unless @user

    @user.reset_password!
  end

  # Step 4: Submit of new password.
  def create
    @user = User.find_by_reset_password_token(params[:reset_password_token])
    raise_404 unless @user

    if @user.update_attributes(password: params[:password],
                               password_confirmation: params[:password_confirm])
      flash[:success] = "Changed password successfully!"
      redirect_to @user
    else
      render[:new]
    end
  end

end
