class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @tag = params[:tag].to_s.strip

    if @tag.present?
      @inventories = Inventory.joins(:tags).where(tags: { name: @tag }).includes(:user, :category).latest
      @items = Item.none
    elsif @query.present?
      @inventories = Inventory.search_with_tags(@query).includes(:user, :category).latest.limit(50)
      @items = Item.search(@query).includes(:inventory).limit(50)
    else
      @inventories = Inventory.none
      @items = Item.none
    end
  end
end
