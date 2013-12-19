class UserSessionsController < ApplicationController

  def new

  end

  def create
    user = User.find_by_credentials(params[:user_email], params[:user_password])

    if user
      login_user!(user)

      redirect_to user, notice: "Welcome back #{user.fname}!"
    else
      flash[:login] = "Incorrect email/password combination."
      redirect_to new_user_session_url
    end
  end

  def destroy
    user = current_user
    logout_current_user!
    redirect_to root_url, notice: "Logged out successfuly. Bye #{user.fname}."
  end

end
