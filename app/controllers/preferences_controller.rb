class PreferencesController < ApplicationController
  def update
    cookies.permanent[:locale] = params[:locale] if params[:locale].presence_in(I18n.available_locales.map(&:to_s))
    cookies.permanent[:theme] = params[:theme] if params[:theme].presence_in(%w[light dark])
    redirect_back_or_to root_path
  end
end
