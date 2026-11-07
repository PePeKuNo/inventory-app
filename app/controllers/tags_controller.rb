class TagsController < ApplicationController
  # JSON autocomplete for the tag input.
  def index
    render json: Tag.starting_with(params[:q]).order(:name).limit(10).pluck(:name)
  end
end
