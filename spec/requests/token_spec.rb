require 'rails_helper'
require 'support/auth_helper'
require 'factory_bot_rails'

RSpec.describe "Token Exchange", type: :request do
  include_examples "Endpoint parameters"

  before :each do
    FactoryBot.create :user
  end

  it "gets a token" do
    get "/authorio/auth", params: params
    verify_params[:code] = Authorio::Request.first.code

    post "/authorio/token", params: verify_params
    expect(response).to be_successful
    expect(json).to have_key('access_token')
  end

  it "validates a token" do
    get "/authorio/auth", params: params
    verify_params[:code] = Authorio::Request.first.code

    post "/authorio/token", params: verify_params
    token = json['access_token']

    get "/authorio/token", params: nil, headers: { 'Authorization': "Bearer #{token}" }
    expect(response).to be_successful
    expect(json).to have_key('me')
  end
end
