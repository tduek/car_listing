class UserSession < ActiveRecord::Base
  attr_accessible :token, :user_id

  belongs_to :user

  before_create :set_unique_token

  def set_unique_token
    self.token = generate_unique_token_for_field(:token)
  end

end
