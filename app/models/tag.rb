class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :inventories, through: :taggings

  scope :starting_with, ->(text) { where("name LIKE ?", "#{sanitize_sql_like(text.to_s.downcase)}%") }

  # Tags with the number of inventories using them, for the tag cloud.
  scope :with_usage, -> {
    joins(:taggings).group(:id).select("tags.id, tags.name, COUNT(taggings.id) AS usage")
  }
end
