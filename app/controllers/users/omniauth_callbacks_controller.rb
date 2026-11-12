class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2 = sign_in_from_provider("Google")
  def github = sign_in_from_provider("GitHub")

  private
    def sign_in_from_provider(kind)
      user = User.from_omniauth(request.env["omniauth.auth"])
      if user.active_for_authentication?
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind:)
      else
        redirect_to new_user_session_path, alert: t("devise.failure.blocked")
      end
    end
end
