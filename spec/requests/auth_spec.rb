require 'rails_helper'
require 'support/auth_helper'
require 'factory_bot_rails'

RSpec.describe "Requests", type: :request do
  let(:params) {
    {
      client_id: 'https://app.example.com',
      redirect_uri: client_redirect_uri,
      state: '1234567',
      code_challenge: "MzlmNjAwYzZkZjMzNTM2NzQwM2MzNTkwYzUzMDE0MjJkNzkxY2NjYjI4OGZkNDAxNzRjMjE1MTAzMzg0YWQ0YQ==",
      code_challenge_method: 'S256',
      scope: 'profile+create',
      me: 'http://localhost/'
    }
  }

  let(:post_params) {
    {
      client: 'https://example.net/',
      url: 'http://example.com/',
      password: 'password'
    }
  }

  let(:verify_params) {
    {
      grant_type: 'authorization_code',
      code: 'deadbeef',
      client_id: 'https://example.net/',
      redirect_uri: client_redirect_uri,
      code_verifier: 'a6128783714cfda1d388e2e98b6ae8221ac31aca31959e59512c59f5'
    }
  }

  it "requires all necessary params" do
    expect { get "/authorio/auth" }.to raise_error ActionController::ParameterMissing
  end

  before :each do
    FactoryBot.create :request
  end

  it "renders the authorization interface" do
    get "/authorio/auth", params: params
    expect(response.body).
      to include("Authorio")
  end

  it "requires valid user URL" do
    params[:me] = 'http://localhost:3000/foo'
    expect { get "/authorio/auth", params: params }.
      to raise_error ActiveRecord::RecordNotFound
  end

  it "flashes message for incorrect password" do
    post_params[:password] = 'wrong'
    post "/authorio/authorize_user", params: post_params
    expect(flash[:alert]).to include("Incorrect password")
  end

  it "redirects on successful authentication" do
    post "/authorio/authorize_user", params: post_params
    expect(response).to redirect_to client_redirect_uri
  end

  it "verifies correct code" do
    post "/authorio/auth", params: verify_params
    expect(response).to be_successful
    expect(json['me']).to include('example.com')
  end

  it "rejects incorrect code" do
    verify_params[:code] = 'wrong'
    post "/authorio/auth", params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it "rejects client mismatch" do
    verify_params[:client_id] = 'wrong'
    post "/authorio/auth", params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it "rejects expired codes" do
    req = Authorio::Request.first
    req.created_at = Time.now - 1.day
    req.save
    post "/authorio/auth", params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it "rejects invalid code_challenge" do
    get "/authorio/auth", params: params
    verify_params[:code_verifier] = 'wrong'
    post "/authorio/auth", params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it "accepts valid code_verifier" do
    get "/authorio/auth", params: params
    post "/authorio/auth", params: verify_params
    expect(response).to be_successful
  end
end
