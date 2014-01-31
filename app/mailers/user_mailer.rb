class UserMailer < ActionMailer::Base
  default from: "no-reply@tommyscars.com"

  def initial_activation_email(user)
    user.reset_activation_token!
    user.update_attribute(:activation_email_sent_at, Time.now)

    @user = user
    mail(to: user.email, subject: "Welcome to Tommy's Cars! Please activate your account.")
  end

  def change_email_verification_email(user)
    user.reset_activation_token!
    user.update_attribute(:activation_email_sent_at, Time.now)

    @user = user
    mail(to: user.email, subject: "Please verify your new email address")
  end

  def reset_password_email(user)
    mail(to: user.email, subject: "Password reset instructions.")
  end

end
