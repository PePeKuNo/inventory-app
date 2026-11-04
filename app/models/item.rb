class Item < ApplicationRecord
  include PgSearch::Model

  belongs_to :inventory
  belongs_to :user
  has_many :likes, dependent: :destroy

  before_validation :assign_custom_id, on: :create

  validates :custom_id, presence: true, uniqueness: { scope: :inventory_id }

  pg_search_scope :search,
    against: %i[custom_id custom_string1 custom_string2 custom_string3 custom_text1 custom_text2 custom_text3],
    using: { tsearch: { prefix: true } }

  def liked_by?(user)
    user.present? && likes.exists?(user_id: user.id)
  end

  private
    # A new item gets the next sequence number and an ID built from the inventory's format,
    # unless the user typed their own ID.
    def assign_custom_id
      self.sequence_number = inventory.items.maximum(:sequence_number).to_i + 1
      self.custom_id = inventory.generate_custom_id(sequence_number) if custom_id.blank?
    end
end
