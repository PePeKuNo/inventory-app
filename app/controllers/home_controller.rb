class HomeController < ApplicationController
  def index
    @latest = Inventory.latest.includes(:user, :category).limit(10)
    @popular = Inventory.most_popular.includes(:user, :category).limit(5)
    @tags = Tag.with_usage
  end

  # Static privacy policy page (Google requires one for the OAuth sign-in).
  def privacy
  end
end
