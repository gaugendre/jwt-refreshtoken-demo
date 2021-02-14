Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3001'

    resource '/api',
             headers: [:Authorization],
             methods: [:post]

    resource '/users/api/sign_in',
             credentials: true,
             headers: :any,
             expose: [:Authorization],
             methods: [:post]

    resource '/users/api/refresh_token',
             credentials: true,
             headers: :any,
             expose: [:Authorization],
             methods: [:post]

    resource '/users/api/sign_out',
             credentials: true,
             headers: :any,
             methods: [:delete]
  end
end
