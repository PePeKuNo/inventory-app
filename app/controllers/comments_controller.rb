class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    inventory = Inventory.find(params[:inventory_id])
    inventory.comments.create(user: current_user, body: params.require(:comment).permit(:body)[:body])
    # The new post itself arrives through the broadcast.
    head :no_content
  end
end
