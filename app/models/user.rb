class ActiveRecord::Base
  def generate_unique_token_for_field(field)
    begin
      token = SecureRandom.base64(32)
    end until !self.class.exists?(field => token)

    token
  end
end

class User < ActiveRecord::Base
  attr_accessible :address_line_1, :address_line_2, :city, :state, :email, :fname, :lname, :phone, :zip, :password, :password_confirmation

  has_many :sessions, class_name: "UserSession"

  has_many :listings, inverse_of: :seller, foreign_key: :seller_id
  has_many :favorites
  has_many :favorited_listings, through: :favorites, source: :listing

  belongs_to :zip, primary_key: :code, foreign_key: :zipcode

  validates :fname, :lname, :email, :phone, :address_line_1, :city, :zip, presence: true

  before_validation { [self.fname, self.lname].each { |n| n.capitalize! if n } }
  validates :fname, :lname, length: 2..30, format: {with: /[a-z\s-]+/i}

  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}, uniqueness: true

  before_validation { self.phone.gsub!(/\D/, "") if self.phone }
  validates :phone, numericality: true, length: {is: 10, message: "should have 10 digits"}

  validates :zip, numericality: true, length: {is: 5}

  # Password logic
  before_validation :set_password_digest, if: :password_required?
  attr_accessor :password, :password_confirmation, :password_required
  validates :password, presence: true, length: {minimum: 8}, if: :password_required?
  validates_confirmation_of :password, if: :password_required?

  # Activation
  before_create :ensure_activation_token

  def favorited_listing?(listing)
    self.favorites.exists?(listing_id: listing.id)
  end

  def password_required?
    !persisted? || password_digest_changed? || password_required
  end

  def password_required!
    self.password_required = true
  end

  def set_password_digest
    if self.password
      self.password_digest = BCrypt::Password.create(self.password).to_s
    end
  end

  def self.within_miles_from_zip(dist, zip)
    User.select('users.*, near_zips.distance')
        .joins(<<-SQL)
          INNER JOIN (#{ Zip.near(dist, zip).to_sql }) AS near_zips
                  ON near_zips.code=users.zipcode
        SQL
  end

  def self.find_by_credentials(email, password)
    user = self.find_by_email(email)
    (user && user.is_password?(password)) ? user : nil
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def name
    [fname, lname].compact.join(" ")
  end

  def ensure_activation_token
    activation_token = generate_unique_token_for_field(:activation_token)

    self.activation_token ||= activation_token
  end

  def reset_activation_token!
    self.activation_token = generate_unique_token_for_field(:activation_token)
    self.is_activated = false
    self.save
  end

  def activate!
    self.update_attribute(:is_activated, true)
  end

  def user
    self
  end

  def reset_password!
    self.password_required!
    password = SecureRandom.base64
    self.update_attributes(password: password, password_confirmation: password)
  end

  def location
    location = "#{ self.zip.city }, #{ self.zip.st }"
    if self.respond_to?(:distance)
      location += " (#{ self.distance.to_f.round } #{ 'mile'.pluralize(self.distance.to_f.round) } away)"
    end

    location
  end
end
