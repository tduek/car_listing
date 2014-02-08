module UserSessionsHelper

  def signin_user!(user)
    @current_user = user

    user_session = user.sessions.create
    session[:user_session_token] = user_session.token
  end

  def current_user
    return nil unless session[:user_session_token]
    user_session = UserSession.find_by_token(session[:user_session_token])
    @current_user ||= user_session.user if user_session
  end

  def user_signed_in?
    !!current_user
  end

  def signout_current_user!
    user_session = UserSession.find_by_token(session[:user_session_token])

    user_session.destroy if user_session
    session[:user_session_token] = nil
  end

end
