require 'rails_helper'

RSpec.describe 'DELETE /users/sign_out', type: :request do
  let(:url) { '/signout' }

  let(:jti) { '347af501-5c74-4976-ae70-89e935647ca5' }
  let(:exp) { 1_584_549_783 }
  let(:jwt) do
    JWT.encode(
      { scp: 'user', exp: exp, jti: jti },
      ENV['DEVISE_JWT_SECRET_KEY'],
      'HS256'
    )
  end
  let(:headers) { { Authorization: "Bearer #{jwt}" } }

  before { delete(url, headers: headers) }

  it 'returns 204, no content' do
    expect(response).to have_http_status(:no_content)
  end

  it 'adds jit to the blacklist' do
    expect(JwtBlacklist.last).to have_attributes(jti: jti, exp: Time.zone.at(exp))
  end
end