# frozen_string_literal: true

class Users::ApiSessionsController < DeviseController
  # before_action :configure_sign_in_params, only: [:create]
  prepend_before_action :require_no_authentication, only: [:create]
  prepend_before_action :allow_params_authentication!, only: :create
  prepend_before_action :verify_signed_out_user, only: :destroy
  prepend_before_action(only: [:create, :refresh_token, :destroy]) { request.env["devise.skip_timeout"] = true }

  # POST /resource/api/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    head :ok
  end

  # POST /resource/api/refresh_token
  # get a new short lived JWT access token
  # by using a long lived session httpOnly cookie
  def refresh_token
    # the route is already hooked up for session check and jwt dispatch
    head :ok
  end

  # DELETE /resource/api/sign_out
  def destroy
    _signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    head :no_content
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  def translation_scope
    'devise.sessions'
  end

  private

  # Check if there is no signed in user before doing the sign out.
  #
  # If there is no signed in user, it will set the flash message and redirect
  # to the after_sign_out path.
  def verify_signed_out_user
    head :no_content if all_signed_out?
  end

  def all_signed_out?
    users = Devise.mappings.keys.map { |s| warden.user(scope: s, run_callbacks: false) }

    users.all?(&:blank?)
  end
end
