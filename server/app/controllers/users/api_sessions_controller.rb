# frozen_string_literal: true

class Users::ApiSessionsController < DeviseController
  include Warden::JWTAuth::Import['expiration_time']

  respond_to :json
  skip_before_action :verify_authenticity_token

  # require params authentification
  prepend_before_action :allow_params_authentication!, only: :create
  # = disable cookie authentification
  prepend_before_action(only: :create) { request.env.delete('HTTP_COOKIE') }

  prepend_before_action :verify_signed_out_user, only: :destroy

  before_action do
    @now ||= Time.now
  end

  # POST /resource/api/sign_in
  def create
    self.resource = warden.authenticate!(scope: resource_name)
    sign_in(resource_name, resource)

    render json: {}.merge(current_session_as_refresh_token)
                   .merge(prepared_jwt_as_access_token)
  end

  # POST /resource/api/refresh_token
  # get a new short lived JWT access token
  # by using a long lived session httpOnly cookie
  def refresh_token
    warden.authenticate!(scope: resource_name)
    # the route is already hooked up for session check and jwt dispatch
    render json: {}.merge(prepared_jwt_as_access_token)
  end

  # DELETE /resource/api/sign_out
  def destroy
    _signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    head :no_content
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

  def prepared_jwt_as_access_token
    jwt = request.env[Warden::JWTAuth::Hooks::PREPARED_TOKEN_ENV_KEY]

    # if !jwt && resource.respond_to?(:jwt_subject)
    #   aud = Warden::JWTAuth::EnvHelper.aud_header(request.env)
    #   jwt, payload = Warden::JWTAuth::UserEncoder.new.call(resource, resource_name, aud)
    # end

    # expiry = payload ? payload['exp'] : @now.to_i + expiration_time
    expiry = @now.to_i + expiration_time

    { access_token: jwt,
      access_token_expiry: expiry }
  end

  def current_session_as_refresh_token
    expires = [
      resource.respond_to?(:timeout_in) && resource.timeout_in,
      resource.respond_to?(:remember_expires_at) && resource.remember_expires_at
    ]

    expiry = expires.map(&:presence).compact.max

    # { refresh_token: stored_cookie_session,
    #   refresh_token_expiry: expiry&.to_i }

    # usefull for the client to trigger a refresh
    # before hitting an unauthorized response
    # on the refresh endpoint
    { refresh_token_expiry: expiry&.to_i }
  end

  # def stored_cookie_session
  #   sess_options = request.env[Rack::RACK_SESSION_OPTIONS]
  #   store = sess_options.instance_variable_get('@by')
  #   cookies[store] if store.is_a?(ActionDispatch::Session::CookieStore)
  # end
end
