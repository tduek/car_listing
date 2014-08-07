module UserSessionsHelper

  def signin_user!(user)
    @current_user = user
    user_session = user.sessions.create!

    if params[:remember_me]
      cookies.permanent[:user_session_token] = user_session.token
    else
      cookies[:user_session_token] = user_session.token
    end
  end

  def current_user
    return nil unless cookies[:user_session_token]
    return @current_user if @current_user

    user_session = UserSession.find_by_token(cookies[:user_session_token])
    @current_user ||= user_session.user if user_session
  end

  def user_signed_in?
    !!current_user
  end

  def signout_current_user!
    user_session = UserSession.find_by_token(cookies[:user_session_token])

    user_session.destroy if user_session
    cookies.delete(:user_session_token)
  end

end
