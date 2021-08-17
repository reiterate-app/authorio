require 'rails_helper'
require 'support/auth_helper'
require 'factory_bot_rails'

RSpec.describe "Token Exchange", type: :request do
  include_examples "Endpoint parameters"

  before :each do
    FactoryBot.create :user
    post_params[:scope] = { scope: %w[profile email] }
  end

  it "gets a token" do
    get '/authorio/auth', params: params
    post '/authorio/user/authorize', params: post_params
    verify_params[:code] = Authorio::Request.first.code

    post "/authorio/token", params: verify_params
    expect(response).to be_successful
    expect(json).to have_key('access_token')
  end

  it "validates a token" do
    get '/authorio/auth', params: params
    post '/authorio/user/authorize', params: post_params
    verify_params[:code] = Authorio::Request.first.code

    post "/authorio/token", params: verify_params
    token = json['access_token']

    get "/authorio/token", params: nil, headers: { 'Authorization': "Bearer #{token}" }
    expect(response).to be_successful
    expect(json).to have_key('me')
  end

  it "rejects invalid token" do
    get "/authorio/token", params: nil, headers: { 'Authorization': "Bearer hAck3dT0k3n" }
    
    expect(response).to have_http_status :bad_request
  end

  it "rejects expired token" do
    get '/authorio/auth', params: params
    post '/authorio/user/authorize', params: post_params
    verify_params[:code] = Authorio::Request.first.code

    post "/authorio/token", params: verify_params
    token = json['access_token']

    stored_token = Authorio::Token.first
    stored_token.expires_at = Time.now - 1.minute
    stored_token.save

    get "/authorio/token", params: nil, headers: { 'Authorization': "Bearer #{token}" }
    expect(response).to have_http_status :unauthorized
  end
end
