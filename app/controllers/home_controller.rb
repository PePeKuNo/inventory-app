class HomeController < ApplicationController
  def index
    @latest = Inventory.latest.includes(:user, :category).limit(10)
    @popular = Inventory.most_popular.includes(:user, :category).limit(5)
    @tags = Tag.with_usage
  end
end
