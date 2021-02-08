class ApiController < ActionController::API
  before_action :authenticate_user!

  def index
    
  end

end
