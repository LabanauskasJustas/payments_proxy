require 'rails_helper'

RSpec.describe 'POST /users/sign_in', type: :request do
  let(:user) { create(:user) }
  let(:url) { '/signin' }

  context 'when params are correct' do
    let(:params) do
      {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end

    before { post(url, params: params) }

    it 'returns status 201' do
      expect(response).to have_http_status(:created)
    end

    it 'returns user information' do
      expect(response).to match_json_schema('user')
    end

    it 'returns JWT token in authorization header' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns valid JWT token' do
      token_from_request = response.headers['Authorization'].split(' ').last
      decoded_token = JWT.decode(token_from_request, ENV['DEVISE_JWT_SECRET_KEY'], true)
      expect(decoded_token.first['sub']).to be_present
    end
  end

  context 'when login params are incorrect' do
    let(:params) do
      {
        user: {
          email: user.email,
          password: 'wrong password'
        }
      }
    end

    before { post(url, params: params) }

    it 'returns status 401' do
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not return JWT token in authorization header' do
      expect(response.headers['Authorization']).not_to be_present
    end
  end

  context 'when login params are not passed' do
    before { post(url) }

    it 'returns status 401' do
      expect(response).to have_http_status(:unauthorized)
    end

    it 'does not return JWT token in authorization header' do
      expect(response.headers['Authorization']).not_to be_present
    end
  end
end