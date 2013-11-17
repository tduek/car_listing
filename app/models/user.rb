class User < ActiveRecord::Base
  attr_accessible :address_line_1, :address_line_2, :city, :email, :fname, :lname, :phone, :zip, :password, :password_confirmation

  validates :fname, :lname, :email, :phone, :address_line_1, :city, :zip, presence: true

  before_validation { [self.fname, self.lname].each { |n| n.capitalize! if n } }
  validates :fname, :lname, length: 2..30, format: {with: /[a-z\s-]+/i}

  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

  before_validation { self.phone.gsub!(/\D/, "") if self.phone }
  validates :phone, numericality: true, length: {is: 10}

  validates :zip, numericality: true, length: {is: 5}

  # Password logic
  before_validation :set_password_digest, if: :password_required?
  attr_accessor :password, :password_confirmation, :password_required
  validates :password, :password_confirmation,
            presence: true, length: {minimum: 8}, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validate :password_has_letters_and_numbers, if: :password_required?

  def password_required?
    !persisted? || password_digest_changed? || password_required
  end

  def password_required!
    self.password_required = true
  end

  def password_has_letters_and_numbers
    unless self.password[/\d[a-z]|[a-z]\d+/i]
      errors[:password] << "must have letters and numbers"
    end
  end

  def set_password_digest
    if self.password
      self.password_digest = BCrypt::Password.create(self.password).to_s
    end
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end



end
