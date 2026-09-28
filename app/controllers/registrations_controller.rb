class RegistrationsController < Devise::RegistrationsController
  protected

  # Google users don't know the random password their account got, so they can change
  # their name and email without it. Changing the password itself still needs the current one.
  def update_resource(resource, params)
    if resource.google_account? && params[:password].blank?
      resource.update_without_password(params.except(:current_password, :password, :password_confirmation))
    else
      super
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:name,
                                  :email,
                                  :password,
                                  :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name,
                                  :email,
                                  :password,
                                  :password_confirmation,
                                  :current_password)
  end
end
