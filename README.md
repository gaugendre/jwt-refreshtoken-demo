# API Sessions and JWT for SPAs

=> using the session cookie of your api as a refresh_token for your webapp
["handling JWTs on frontend" take by hasura](https://hasura.io/blog/best-practices-of-using-jwt-with-graphql)

## rails demo server

### features

* based on `active_record` with `devise` and `devise-jwt`
* `Users::ApiSessionsController` demo controller for api sign_in/out and new access tokens
* optional payload with `refresh_token_expiry` on sign_in and `access_token_expiry` on the refresh_token action to provide the client a mean to expire or renew tokens before facing an unauthorized request
* the `access_token` is a json web token which means clients can access expiry timestamps and middlewares can check for authorization validity

### files

* dummy web root with default `devise` install on `User`
  * `home_controller.rb` showing session data
* `devise-jwt` custom implementation for api auth and tokens using httponly session cookie
  * [users/api_sessions_controller.rb](rails-backend/app/controllers/users/api_sessions_controller.rb)
  * [users/api_sessions_request_spec.rb](rails-backend/spec/requests/users/api_sessions_request_spec.rb)
* dummy `POST /api` endpoint accessing session while ignoring cookies
  * [api_controller.rb](rails-backend/app/controllers/api_controller.rb)
  * [api_request_spec.rb](rails-backend/spec/requests/api_request_spec.rb)

### timeouts config

#### short lived access tokens

```ruby
Devise.setup do |config|
  config.jwt do |jwt|
    jwt.expiration_time = 15.minutes # default to 1.hour
  end
end
```

#### session expiration after last token refresh or webapp is closed

##### without remember_me cookie

```ruby
class User < ActiveRecord::Base
  # devise :timeoutable

  def timeout_in
    16.minutes
  end
end
```

##### with remember_me cookie

```ruby
class User < ActiveRecord::Base
  # devise :rememberable

  def remember_for
    10.days # default to 2.weeks
  end

  def extend_remember_period
    true # default to false
  end
end
```

## Demo api clients

### React webapp

simple webapp refreshing tokens before expiration through the cookie but without any JWT decoding

* based on the `fetch` function for api calls and `react-router-dom`
* [utils/inMemoryToken.js](react-app/src/utils/inMemoryToken.js) pure JS to handle authentication state and trigger localStorage event on logout
* [components/AuthContainer.jsx](react-app/src/components/AuthContainer.jsx) to
  * route and wrap private components
  * redirect to `/login` when unauthenticated
  * trigger regular access tokens refreshes before expiration
  * listen to logouts from localStorage
* [components/HomePage.jsx](react-app/src/components/HomePage.jsx) to showcase a request with the access token
