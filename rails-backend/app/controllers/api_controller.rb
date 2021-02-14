class ApiController < ActionController::API
  # we only want jwt strategy to work, no sessions
  prepend_before_action { request.env.delete('HTTP_COOKIE') }
  
  before_action :authenticate_user!

  def index
    render json: {
      session: session.to_h,
      remember_expires_at: current_user.remember_expires_at,
      user: current_user.attributes
    }
  end
end
