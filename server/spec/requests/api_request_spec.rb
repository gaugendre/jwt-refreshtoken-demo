require 'rails_helper'

require_relative './user_jwt_requests_shared'
require_relative './json_api_shared'

RSpec.describe 'Api', type: :request do
  include_context 'jwt on user request'
  include_context 'json api'

  let(:auth_header) do
    { 'Authorization' => "Bearer #{access_token}" }
  end

  describe 'POST /api' do
    context 'without access_token' do
      before { post api_path, headers: accept_header }

      it_behaves_like 'unauthorized response'
      it_behaves_like 'no auth headers'
      it_behaves_like 'error description'
    end

    context 'with an access_token' do
      before { post api_path, headers: accept_header.merge(auth_header) }

      it_behaves_like 'ok response'
      
      it { expect(json_content['user']).to be_present }
    end
  end
end
