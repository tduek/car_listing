class UserSessionsController < ApplicationController

  def new

  end

  def create
    user = User.find_by_credentials(params[:user_email], params[:user_password])

    if user
      signin_user!(user)

      flash[:success] =  "Welcome back #{user.fname}!"
      redirect_to session[:friendly_redirect] || user
    else
      flash[:alert] = "Incorrect email/password combination."
      redirect_to new_user_session_url
    end
  end

  def destroy
    user = current_user
    signout_current_user!
    redirect_to root_url, notice: "Signed out successfuly. Bye #{user.fname}."
  end

end
