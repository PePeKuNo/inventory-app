class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item

  def create
    @item.likes.create(user: current_user) # the unique index stops a second like
    redirect_to inventory_item_path(@item.inventory, @item)
  rescue ActiveRecord::RecordNotUnique
    redirect_to inventory_item_path(@item.inventory, @item)
  end

  def destroy
    @item.likes.find_by(user: current_user)&.destroy
    redirect_to inventory_item_path(@item.inventory, @item)
  end

  private
    def set_item
      @item = Item.where(inventory_id: params[:inventory_id]).find(params[:item_id])
    end
end
