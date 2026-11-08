class AccessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory

  def create
    user = User.find_by(id: params[:user_id])
    @inventory.accesses.find_or_create_by(user:) if user
    redirect_to inventory_path(@inventory, tab: "access")
  end

  def bulk_destroy
    @inventory.accesses.where(user_id: params[:ids]).destroy_all
    redirect_to inventory_path(@inventory, tab: "access")
  end

  private
    def set_inventory
      @inventory = Inventory.find(params[:inventory_id])
      deny_access unless @inventory.editable_by?(current_user)
    end
end
