class Category < ApplicationRecord
  has_many :inventories, dependent: :nullify
end
