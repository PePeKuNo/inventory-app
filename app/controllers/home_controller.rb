class HomeController < ApplicationController
  def index
    @latest = Inventory.latest.limit(10)
    @popular = Inventory.most_popular.limit(5)
  end
end
