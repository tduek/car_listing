class EmailsController < ApplicationController


  def create
    @user = User.find(params[:user_id])
    UserMailer.initial_activation_email(@user).deliver!

    redirect_to @user, notice: "Almost done! Check your inbox for the activation email."
  end


  def update
    @user = User.find(params[:user_id])

    if @user.update_attributes(params[:user])
      UserMailer.change_email_verification_email(@user).deliver!
      notice = "Please verify your new email address. We sent an email to #{@user.email}"
    else
      notice = "Couldn't save the new email address: #{params[:user][:email]}. Please edit below."
    end

    redirect_to @user, notice: notice
  end


end