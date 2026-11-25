class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github]

  has_many :inventories, dependent: :destroy
  has_many :items, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :accesses, dependent: :destroy
  has_many :writable_inventories, through: :accesses, source: :inventory

  validates :name, presence: true

  # The first admin can't be appointed from the UI, so the email from ADMIN_EMAIL becomes admin on sign up.
  before_create { self.admin = true if ENV["ADMIN_EMAIL"].present? && email.casecmp?(ENV["ADMIN_EMAIL"]) }

  scope :matching, ->(query) {
    pattern = "#{sanitize_sql_like(query.to_s.downcase)}%"
    where("LOWER(name) LIKE :p OR LOWER(email) LIKE :p", p: pattern)
  }

  # Blocked users can't sign in (Devise calls this on every request).
  def active_for_authentication?
    super && !blocked?
  end

  def inactive_message
    blocked? ? :blocked : super
  end

  # Finds the user by the social account, or links it to an existing user with the same email.
  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid) || find_or_initialize_by(email: auth.info.email)
    user.provider = auth.provider
    user.uid = auth.uid
    user.name = auth.info.name.presence || auth.info.nickname || auth.info.email if user.name.blank?
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.save!
    user
  end
end
