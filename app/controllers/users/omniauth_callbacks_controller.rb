class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Google sends the user back here after they log in (or cancel)
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: "Google")
      sign_in_and_redirect @user, event: :authentication
    else
      redirect_to new_user_session_path,
                  alert: "Could not log in with Google: #{@user.errors.full_messages.to_sentence}"
    end
  end

  # Cancelled at Google, or something went wrong there
  def failure
    redirect_to new_user_session_path, alert: "Google login was cancelled or failed. Please try again."
  end
end
