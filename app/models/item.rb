class Item < ApplicationRecord
  include PgSearch::Model

  belongs_to :inventory
  belongs_to :user
  has_many :likes, dependent: :destroy

  validates :custom_id, presence: true, uniqueness: { scope: :inventory_id }

  pg_search_scope :search,
    against: %i[custom_id custom_string1 custom_string2 custom_string3 custom_text1 custom_text2 custom_text3],
    using: { tsearch: { prefix: true } }

  def liked_by?(user)
    user.present? && likes.exists?(user_id: user.id)
  end
end
