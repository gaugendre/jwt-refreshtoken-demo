class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @data = {
      cookie_names: cookies.to_h.keys,
      session_cookie: cookies['_server_session'],
      session: session.to_h,
      remember_user_cookie: cookies['remember_user_token'],
      signed_remember_user_cookie: cookies.signed['remember_user_token'],
      remember_expires_at: current_user.remember_expires_at,
      user: current_user.attributes
    }
  end
end
