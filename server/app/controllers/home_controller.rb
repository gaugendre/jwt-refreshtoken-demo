class HomeController < ApplicationController
  before_action :authenticate_user!

  def index

    sess_cookie_parts = cookies['_server_session'].split('--')

    @data = {
      request: {
        headers: request.headers.to_h
      },
      response: {
        headers: response.headers
      },
      devise: {
        mappings: Devise.mappings
      },
      session: {
        session: session.to_h
      },
      cookies: {
        cookies: cookies.to_h,
        encrypted: cookies.encrypted['_server_session']
      },
      server: {
        sess_cookie: sess_cookie_parts
      },
      user: current_user.attributes
    }
  end
end
