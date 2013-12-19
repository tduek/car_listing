class UserSession < ActiveRecord::Base
  attr_accessible :token, :user_id

  belongs_to :user

  before_create :set_unique_token

  def set_unique_token
    begin
      token = SecureRandom.base64(32)
    end until !UserSession.exists?(token: token)

    self.token = token
  end

end
