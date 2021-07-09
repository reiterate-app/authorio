require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe "Requests", type: :request do
  let(:params) {
    {
      client_id: 'https://app.example.com',
      redirect_uri: 'https://app.example.com/redirect',
      state: '1234567',
      code_challenge: 'OfYAxt8zU2dAPDWQxTAUIteRzMsoj9QBdMIVEDOErUo',
      code_challenge_method: 'S256',
      scope: 'profile+create',
      me: 'http://localhost:3000/'
    }
  }

  let(:post_params) {
    {
      client: 'https://example.net',
      url: 'http://localhost/',
      password: 'password'
    }
  }

  it "requires all necessary params" do
    expect { get "/authorio/auth" }.to raise_error ActionController::ParameterMissing
  end

  before :each do
    FactoryBot.create :request
  end

  it "renders the authorization interface" do
    get "/authorio/auth?#{params.to_query}"
    expect(response.body).
      to include("Authorio")
  end

  it "requires valid user URL" do
    params[:me] = 'http://localhost:3000/foo'
    expect { get "/authorio/auth?#{params.to_query}" }.
      to raise_error ActiveRecord::RecordNotFound
  end

  it "flashes message for incorrect password" do
    post_params[:password] = 'wrong'
    post "/authorio/authorize_user", params: post_params
    expect(flash[:alert]).to include("Incorrect password")
  end

  it "redirects on successful authentication" do
    post "/authorio/authorize_user", params: post_params
    expect(response).to redirect_to 'https://example.net/redirect'
  end
end
