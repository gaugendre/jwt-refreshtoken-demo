require 'rails_helper'
require_relative '../user_jwt_requests_shared.rb'

def session_cookie_name(env)
  env[Rack::RACK_SESSION_OPTIONS].instance_variable_get('@by').key
end

RSpec.shared_examples 'response with session as refresh_token' do
  it do
    post request_path, request_params
    content = JSON.parse response.body

    # httponly session cookie
    regex = %r{^#{session_cookie_name(request.env)}=(.+); path=/; HttpOnly$}
    expect(response.headers['Set-Cookie']).to match regex

    # expiration timestamp
    expect(content['refresh_token_expiry']).to be_present
    expect(content['refresh_token_expiry']).to be_kind_of(Integer)
    expect(content['refresh_token_expiry']).to be > Time.now.to_i
  end
end

RSpec.shared_examples 'response with jwt as access_token' do
  it do
    post request_path, request_params
    content = JSON.parse response.body

    # Authorization
    expect(response.headers['Authorization']).to match(/^Bearer (.+)$/)

    # expiration timestamp
    expect(content['access_token_expiry']).to be_present
    expect(content['access_token_expiry']).to be_kind_of(Integer)
    expect(content['access_token_expiry']).to be > Time.now.to_i

    # access_token
    token = response.headers['Authorization'].split[1]
    expect(token).to eq content['access_token']

    # valid jwt
    expect { Warden::JWTAuth::UserDecoder.new.call(token, :user, nil) }.not_to raise_error
  end
end

RSpec.shared_examples 'ok response' do
  it do
    post request_path, request_params

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include('application/json')
  end
end

RSpec.shared_examples 'unauthorized response' do
  it do
    post request_path, request_params
    content = JSON.parse response.body

    expect(response).to have_http_status(:unauthorized)
    expect(response.content_type).to include('application/json')

    expect(response.headers.key?('Set-Cookie')).to be_falsy
    expect(response.headers.key?('Authorization')).to be_falsy
    expect(content.key?('error')).to be_truthy
  end
end

RSpec.shared_examples 'no content' do
  it do
    delete request_path, request_params

    expect(response).to have_http_status(:no_content)
    expect(response.content_type).to be_blank
    expect(response.body).to be_blank

    expect(response.headers.key?('Set-Cookie')).to be_falsy
    expect(response.headers.key?('Authorization')).to be_falsy
  end
end

RSpec.describe 'Users::ApiSessions', type: :request do
  include_context "jwt on user request"

  describe 'sign_in' do
    let(:sign_in_payload) do
      {
        "user": {
          "email": email,
          "password": password
        }
      }
    end

    let(:sign_in_payload_bad_email) do
      {
        "user": {
          "email": 'john@doe.invalid',
          "password": password
        }
      }
    end

    let(:sign_in_payload_bad_password) do
      {
        "user": {
          "email": email,
          "password": 'bad password'
        }
      }
    end

    context 'with no credentials' do
      let(:request_path) { users_api_sign_in_path }

      let(:request_params) do
        { headers: request_headers }
      end

      it_behaves_like 'unauthorized response'
    end

    context 'with good credentials' do
      describe 'is ok with headers and json content' do
        let(:request_path) { users_api_sign_in_path }

        let(:request_params) do
          { params: sign_in_payload.to_json,
            headers: request_headers }
        end

        it_behaves_like 'ok response'
        it_behaves_like 'response with session as refresh_token'
        it_behaves_like 'response with jwt as access_token'
      end
    end

    context 'with bad credentials (email)' do
      let(:request_path) { users_api_sign_in_path }

      let(:request_params) do
        { params: sign_in_payload_bad_email.to_json,
          headers: request_headers }
      end

      it_behaves_like 'unauthorized response'
    end

    context 'with bad credentials (password)' do
      let(:request_path) { users_api_sign_in_path }

      let(:request_params) do
        { params: sign_in_payload_bad_password.to_json,
          headers: request_headers }
      end

      it_behaves_like 'unauthorized response'
    end

    context 'with session but no params' do
      it do
        # successful login
        post users_api_sign_in_path, { params: sign_in_payload.to_json, headers: request_headers }
        @session_cookie = response.headers['Set-Cookie'][session_cookie_name(request.env)]

        # login attenpt without payload
        post users_api_sign_in_path, { headers: request_headers.merge({ 'Cookie' => @session_cookie }) }
        content = JSON.parse response.body

        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to include('application/json')

        expect(response.headers.key?('Set-Cookie')).to be_falsy
        expect(response.headers.key?('Authorization')).to be_falsy
        expect(content.key?('error')).to be_truthy
      end
    end
  end

  describe 'refresh_token' do
    context 'without session' do
      let(:request_path) { users_api_refresh_token_path }

      let(:request_params) do
        { headers: request_headers }
      end

      it_behaves_like 'unauthorized response'
    end
  end 

  describe 'sign_out' do
    context 'with an access_token' do
      let(:request_path) { users_api_sign_out_path }

      let(:request_params) do
        { headers: request_headers.merge({ 'Authorization' => "Bearer #{access_token}" }) }
      end

      it_behaves_like 'no content'
    end

    context 'without access_token' do
      let(:request_path) { users_api_sign_out_path }

      let(:request_params) do
        { headers: request_headers }
      end

      it_behaves_like 'no content'
    end
  end
end
