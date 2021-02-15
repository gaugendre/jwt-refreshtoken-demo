Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true do
  allow do
    origins 'localhost:3001'

    request_profile = {
      headers: %w[Authorization], # must be strings
      methods: [:post]
    }

    auth_profile = {
      credentials: true,
      headers: :any,
      expose: %w[Authorization], # must be strings
      methods: [:post]
    }

    resource '/api', request_profile
    resource '/api/*', request_profile

    resource '/users/api/sign_in', auth_profile
    resource '/users/api/refresh_token', auth_profile

    resource '/users/api/sign_out',
             credentials: true,
             headers: :any,
             methods: [:delete]
  end
end
