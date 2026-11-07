class InventoriesController < ApplicationController
  PUBLIC_TABS = %w[items chat].freeze
  OWNER_TABS = %w[items chat settings].freeze

  before_action :authenticate_user!
  before_action :set_inventory, except: %i[new create bulk_destroy]
  before_action :require_editor, only: %i[update destroy custom_id_preview]

  def show
    @tabs = OWNER_TABS
    @tab = params[:tab].presence_in(@tabs) || "items"
  end

  def new
    @inventory = Inventory.new
  end

  def create
    @inventory = current_user.inventories.new(inventory_params)
    if @inventory.save
      redirect_to inventory_path(@inventory, tab: "settings"), notice: t("flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Used by autosave (JSON) and by normal form submits (HTML).
  # The form sends the lock_version it was loaded with; if somebody saved the inventory
  # in the meantime, Rails raises StaleObjectError instead of overwriting their changes.
  def update
    if @inventory.update(inventory_params)
      respond_to do |format|
        format.json { render json: { lock_version: @inventory.lock_version } }
        format.html { redirect_to inventory_path(@inventory, tab: params[:tab]), notice: t("flash.saved") }
      end
    else
      respond_to do |format|
        format.json { render json: { error: @inventory.errors.full_messages.to_sentence }, status: :unprocessable_entity }
        format.html { redirect_to inventory_path(@inventory, tab: params[:tab]), alert: @inventory.errors.full_messages.to_sentence }
      end
    end
  rescue ActiveRecord::StaleObjectError
    respond_to do |format|
      format.json { render json: { error: t("flash.stale") }, status: :conflict }
      format.html { redirect_to inventory_path(@inventory, tab: params[:tab]), alert: t("flash.stale") }
    end
  end

  def destroy
    @inventory.destroy!
    redirect_to user_path(current_user), notice: t("flash.deleted")
  end

  def bulk_destroy
    scope = current_user.admin? ? Inventory.all : current_user.inventories
    scope.where(id: params[:ids]).destroy_all
    redirect_back_or_to user_path(current_user), notice: t("flash.deleted")
  end

  # Live example for the "Custom ID" tab, built with the same code that builds real IDs.
  def custom_id_preview
    elements = params.fetch(:inventory, {}).permit(custom_id_format: %i[type format])[:custom_id_format]
    draft = Inventory.new(custom_id_format: elements || [])
    next_sequence = @inventory.items.maximum(:sequence_number).to_i + 1
    render plain: draft.generate_custom_id(next_sequence)
  end

  private
    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

    def require_editor
      deny_access unless @inventory.editable_by?(current_user)
    end

    def inventory_params
      params.require(:inventory).permit(
        :title, :description, :category_id, :image_url, :tag_list, :is_public, :lock_version,
        *Inventory.field_setting_columns, custom_id_format: [ [ :type, :format ] ]
      )
    end
end
