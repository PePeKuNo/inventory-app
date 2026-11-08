class UsersController < ApplicationController
  # JSON autocomplete for the "Access" tab: matches by name or email prefix.
  def index
    users = User.matching(params[:q]).order(:name).limit(10)
    render json: users.map { |user| { id: user.id, name: user.name, email: user.email } }
  end
end
