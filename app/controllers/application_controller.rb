class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale

  helper_method :current_theme

  private
    # Language and theme are kept in permanent cookies, so they work for guests too.
    def switch_locale(&action)
      locale = cookies[:locale].presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale
      I18n.with_locale(locale, &action)
    end

    def current_theme
      cookies[:theme] == "dark" ? "dark" : "light"
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
      devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
    end

    def deny_access
      redirect_back_or_to root_path, alert: t("flash.forbidden")
    end
end
