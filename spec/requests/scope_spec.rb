require 'rails_helper'
require 'support/auth_helper'
require 'factory_bot_rails'

RSpec.describe "Auth Scope", type: :request do
  include_examples "Endpoint parameters"

  before :each do
    FactoryBot.create :user
  end

  it "hides scopes when none given" do
    params[:scope] = nil
    get "/authorio/auth", params: params
    expect(response.body).to_not include("View basic profile")
  end

  it "shows profile and email scope when requested" do
    params[:scope] = "profile email"
    get "/authorio/auth", params: params
    expect(response.body).to include("View basic profile")
    expect(response.body).to include("View your email")
  end

  it "returns profile information" do
    user = Authorio::User.first
    params[:scope] = "profile email"
    get "/authorio/auth", params: params
    post_params[:scope] = { scope: ['profile', 'email'] }
    post "/authorio/users/1/authorize", params: post_params
    expect(response).to redirect_to %r(\A#{client_redirect_uri})

    verify_params[:code] = Authorio::Request.first.code
    post "/authorio/auth", params: verify_params
    expect(response).to be_successful
    expect(json['me']).to include('example.com')

    expect(json).to have_key('profile')
    expect(json['profile']['name']).to eq(user.full_name)
    expect(json['profile']['email']).to eq(user.email)
    expect(json['profile']['url']).to eq(user.url)
  end

  it "hides email if requested" do
    user = Authorio::User.first
    params[:scope] = "profile email"
    get "/authorio/auth", params: params
    post_params[:scope] = { scope: ['profile'] }
    post "/authorio/users/1/authorize", params: post_params

    verify_params[:code] = Authorio::Request.first.code
    post "/authorio/auth", params: verify_params

    expect(json).to have_key('profile')
    expect(json['profile']).to_not have_key('email')
  end

  it "handles missing scope" do
    params.delete :scope
    get "/authorio/auth", params: params
    post_params.delete :scope
    post "/authorio/users/1/authorize", params: post_params
    expect(response).to redirect_to %r(\A#{client_redirect_uri})
  end
end
