class Comment < ApplicationRecord
  belongs_to :inventory
  belongs_to :user

  validates :body, presence: true

  # Every viewer of the inventory page is subscribed to this stream,
  # so a new post appears for all of them without reloading.
  after_create_commit -> { broadcast_append_to inventory, :comments, target: "comments" }
end
