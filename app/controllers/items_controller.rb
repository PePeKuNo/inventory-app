class ItemsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_inventory
  before_action :require_writer, only: %i[new create update bulk_destroy]
  before_action :set_item, only: %i[show update]

  # CSV export of the whole inventory.
  def index
    respond_to do |format|
      format.csv { send_data @inventory.items_csv, filename: "#{@inventory.title.parameterize}.csv" }
    end
  end

  def show
    @editable = @inventory.writable_by?(current_user)
  end

  def new
    @item = @inventory.items.new
  end

  def create
    @item = @inventory.items.new(item_params.merge(user: current_user))
    if save_item
      redirect_to inventory_path(@inventory), notice: t("flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @item.assign_attributes(item_params)
    if save_item
      redirect_to inventory_item_path(@inventory, @item), notice: t("flash.saved")
    else
      @editable = true
      render :show, status: :unprocessable_entity
    end
  rescue ActiveRecord::StaleObjectError
    @editable = true
    @stale = true
    flash.now[:alert] = t("flash.stale")
    render :show, status: :conflict
  end

  def bulk_destroy
    @inventory.items.where(id: params[:ids]).destroy_all
    redirect_to inventory_path(@inventory), notice: t("flash.deleted")
  end

  private
    def set_inventory
      @inventory = Inventory.find(params[:inventory_id])
    end

    def set_item
      @item = @inventory.items.find(params[:id])
    end

    def require_writer
      deny_access unless @inventory.writable_by?(current_user)
    end

    # The validation catches most duplicate IDs, the unique DB index catches the rest
    # (two users saving the same ID at the same moment).
    def save_item
      @item.save
    rescue ActiveRecord::RecordNotUnique
      @item.errors.add(:custom_id, :taken)
      false
    end

    def item_params
      params.require(:item).permit(:custom_id, :lock_version, *@inventory.custom_fields.map(&:key))
    end
end
