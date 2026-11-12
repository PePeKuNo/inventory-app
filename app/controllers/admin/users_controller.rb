class Admin::UsersController < ApplicationController
  ACTIONS = {
    "block" => { blocked: true },
    "unblock" => { blocked: false },
    "make_admin" => { admin: true },
    "remove_admin" => { admin: false }
  }.freeze

  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = User.order(:name)
  end

  def bulk_update
    changes = ACTIONS.fetch(params[:operation])
    User.where(id: params[:ids]).update_all(changes)
    # An admin may remove their own admin role; then they can't stay on this page.
    if current_user.reload.admin?
      redirect_to admin_users_path, notice: t("flash.saved")
    else
      redirect_to root_path, notice: t("flash.saved")
    end
  end

  def bulk_destroy
    User.where(id: params[:ids]).destroy_all
    redirect_to admin_users_path, notice: t("flash.deleted")
  end

  private
    def require_admin
      deny_access unless current_user.admin?
    end
end
