require 'rails_helper'

require_relative '../user_jwt_requests_shared'
require_relative '../json_api_shared'

def session_cookie_name(env)
  env[Rack::RACK_SESSION_OPTIONS].instance_variable_get('@by').key
end

RSpec.shared_examples 'httponly session cookie' do
  it do
    expect(response.headers['Set-Cookie']).to match(
      %r{^#{session_cookie_name(request.env)}=(.+); path=/; HttpOnly$}
    )
  end
end

RSpec.shared_examples 'jwt as access_token' do
  let(:auth_header) do
    response.headers['Authorization']
  end

  let(:token) do
    auth_header.split[1]
  end

  let(:decoded_jwt) do
    Warden::JWTAuth::UserDecoder.new.call(token, :user, nil)
  end

  it do
    expect(auth_header).to match(/^Bearer (.+)$/)
    expect(json_content['access_token']).to eq token
    expect { decoded_jwt }.not_to raise_error
  end
end

RSpec.shared_examples 'expiration timestamp' do |expiration_key|
  it do
    expect(json_content[expiration_key.to_s]).to be_present
    expect(json_content[expiration_key.to_s]).to be_kind_of(Integer)
    expect(json_content[expiration_key.to_s]).to be > Time.now.to_i
  end
end

RSpec.describe 'Users::ApiSessions', type: :request do
  include_context 'jwt on user request'
  include_context 'json api'

  describe '/users/api/sign_in' do
    context 'with no credentials' do
      before { post users_api_sign_in_path, { headers: accept_header } }

      it_behaves_like 'unauthorized response'
      it_behaves_like 'no auth headers'
    end

    context 'with good credentials' do
      before do
        post users_api_sign_in_path, {
          params: sign_in_payload.to_json,
          headers: accept_header.merge(content_type_header)
        }
      end

      it_behaves_like 'ok response'

      it_behaves_like 'httponly session cookie'
      it_behaves_like 'expiration timestamp', :refresh_token_expiry

      it_behaves_like 'jwt as access_token'
      it_behaves_like 'expiration timestamp', :access_token_expiry
    end

    context 'with bad credentials (email)' do
      before do
        post users_api_sign_in_path, {
          params: sign_in_payload_bad_email.to_json,
          headers: accept_header.merge(content_type_header)
        }
      end

      it_behaves_like 'unauthorized response'
      it_behaves_like 'no auth headers'
      it_behaves_like 'error description'
    end

    context 'with bad credentials (password)' do
      before do
        post users_api_sign_in_path, {
          params: sign_in_payload_bad_password.to_json,
          headers: accept_header.merge(content_type_header)
        }
      end

      it_behaves_like 'unauthorized response'
      it_behaves_like 'no auth headers'
      it_behaves_like 'error description'
    end

    context 'with session but no params' do
      before do
        # successful login
        post users_api_sign_in_path, {
          params: sign_in_payload.to_json,
          headers: accept_header.merge(content_type_header)
        }

        @session_cookie = response.headers['Set-Cookie'][session_cookie_name(request.env)]

        # login attenpt without payload
        post users_api_sign_in_path, {
          headers: accept_header.merge({ 'Cookie' => @session_cookie })
        }
      end

      it_behaves_like 'unauthorized response'
      it_behaves_like 'no auth headers'
      it_behaves_like 'error description'
    end
  end

  describe '/users/api/refresh_token' do
    context 'without session' do
      before { post users_api_refresh_token_path, headers: accept_header }

      it_behaves_like 'unauthorized response'
      it_behaves_like 'no auth headers'
      it_behaves_like 'error description'
    end
  end

  describe '/users/api/sign_out' do
    context 'with an access_token' do
      before do
        delete users_api_sign_out_path, {
          headers: accept_header.merge({ 'Authorization' => "Bearer #{access_token}" })
        }
      end

      it_behaves_like 'no content response'
      it_behaves_like 'no auth headers'
    end

    context 'without access_token' do
      before { delete users_api_sign_out_path }

      it_behaves_like 'no content response'
      it_behaves_like 'no auth headers'
    end
  end
end
