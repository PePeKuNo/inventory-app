class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    inventory = Inventory.find(params[:inventory_id])
    inventory.comments.create(user: current_user, body: params.require(:comment).permit(:body)[:body])
    # The new post itself arrives through the broadcast; here we only reset the form.
    render turbo_stream: turbo_stream.replace("new_comment", partial: "comments/form", locals: { inventory: })
  end
end
