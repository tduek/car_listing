class ActiveRecord::Base
  def generate_unique_token_for_field(field)
    begin
      token = SecureRandom.base64(32)
    end until !self.class.exists?(field => token)

    token
  end
end

class User < ActiveRecord::Base
  attr_accessible :address_line_1, :address_line_2, :city, :state, :email, :fname, :lname, :phone, :zipcode, :password, :password_confirmation, :new_email

  has_many :sessions, class_name: "UserSession"

  has_many :listings, inverse_of: :seller, foreign_key: :seller_id
  has_many :favorites
  has_many :favorited_listings, through: :favorites, source: :listing

  belongs_to :zip, primary_key: :code, foreign_key: :zipcode

  validates :fname, :lname, :email, :phone, :address_line_1, :city, :zip,
    presence: true,
    if: :is_real_user?

  validates :fname, :lname,
    length: 2..30,
    format: { with: /[a-z\s-]+/i },
    if: :is_real_user?

  validate :email_validation

  before_validation { self.phone.gsub!(/\D/, '') if self.phone.is_a?(String) }
  validates :phone,
    numericality: true,
    length: { is: 10, message: "should have 10 digits" }

  validates :zipcode,
    numericality: true,
    length: { is: 5 }

  validate :phone_format

  # Password logic
  attr_reader :password, :password_confirmation, :password_required
  validates :password, length: {minimum: 8, allow_nil: true }
  validates_confirmation_of :password

  # Activation
  before_create :ensure_activation_token

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

  def self.find_by_email(email)
    where('lower(email) = ?', email.to_s.downcase).first
  end

  def phone_format
    phone_s = phone.to_s
    unless phone_s.length == 10 || (phone_s.length == 11 && phone_s[0] == '1')
      errors[:phone] << "is invalid"
    end
  end

  def phone=(val)
    write_attribute(:phone, val.to_s.gsub(/\D/, '').to_i)
  end

  def email_validation
    return unless self.is_real_user?

    email = self.new_email || self.email

    preexisting = User
      .where('lower(email) = :email OR lower(new_email) = :email', email: email)
      .first
    errors[:email] << 'is taken' if preexisting && preexisting != self

    unless email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
      errors[:email] << 'is not a valid email address'
    end
  end

  def favorited_listing?(listing)
    self.favorites.exists?(listing_id: listing.id)
  end

  def password_required!
    @password_required = true
  end

  def password=(unencrypted_password)
    if unencrypted_password.present?
      @password = unencrypted_password
      self.password_digest = BCrypt::Password.create(unencrypted_password).to_s
    end
  end

  def password_confirmation=(unencrypted_password)
    if unencrypted_password.present?
      @password_confirmation = unencrypted_password
    end
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
    self.save!
  end

  def reset_forgot_password_token!
    self.forgot_password_token = generate_unique_token_for_field(:forgot_password_token)
    self.save!
  end

  def activate!
    self.is_activated = true

    if self.new_email.present?
      self.email, self.new_email = self.new_email, nil
    end
    self.activation_token = generate_unique_token_for_field(:activation_token)

    self.reset_activation_token!
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
