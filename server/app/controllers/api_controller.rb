class ApiController < ActionController::API
  before_action :authenticate_user!

  def index
    render json: {
      session: session.to_h,
      remember_expires_at: current_user.remember_expires_at,
      user: current_user.attributes
    }
  end
end
