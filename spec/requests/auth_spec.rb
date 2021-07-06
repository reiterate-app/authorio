require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe "Requests", type: :request do
  it "requires all necessary params" do
    
    expect { get "/authorio/auth" }.to raise_error ActionController::ParameterMissing
  end
    
  params = {
    client_id: 'https://app.example.com',
    redirect_uri: 'https://app.example.com/redirect',
    state: '1234567',
    code_challenge: 'OfYAxt8zU2dAPDWQxTAUIteRzMsoj9QBdMIVEDOErUo',
    code_challenge_method: 'S256',
    scope: 'profile+create',
    me: 'http://localhost:3000/'
  }

  before :each do
    FactoryBot.create :user
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
end
