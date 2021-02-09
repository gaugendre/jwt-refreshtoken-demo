require 'rails_helper'
require_relative './user_jwt_requests_shared.rb'

RSpec.describe 'Api', type: :request do
  include_context "jwt on user request"

  describe 'POST /api' do
    context 'with an access_token' do
      let(:request_params) do
        { headers: request_headers.merge({ 'Authorization' => "Bearer #{access_token}" }) }
      end

      it 'works! (now write some real specs)' do
        post api_path, request_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without access_token' do
      let(:request_params) do
        { headers: request_headers }
      end

      it do
        post api_path, request_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
