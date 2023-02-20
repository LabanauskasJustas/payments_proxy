require 'rails_helper'

RSpec.describe 'POST /users', type: :request do
  let(:url) { '/users' }
  let(:params) do
    {
      user: {
        email: 'user@example.com',
        password: 'password'
      }
    }
  end

  context 'when user is not registered' do
    before { post(url, params: params) }

    it 'returns status 201' do
      expect(response).to have_http_status(:created)
    end

    it 'returns a new user' do
      expect(response).to match_json_schema('user')
    end
  end

  context 'when user already exists' do
    let(:expected_response) { { 'errors' => { 'email' => ['has already been taken'] } } }

    before do
      create(:user, email: params[:user][:email])
      post(url, params: params)
    end

    it 'returns status 422' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns validation errors' do
      expect(JSON.parse(response.body)).to eq(expected_response)
    end
  end
end