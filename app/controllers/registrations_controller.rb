class RegistrationsController < Devise::RegistrationsController
  protected

  # Accounts created with Google have no password: they change their name and email
  # without one, and can't set a password (they always log in with Google).
  def update_resource(resource, params)
    if resource.google_only?
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
