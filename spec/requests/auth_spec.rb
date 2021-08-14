# frozen_string_literal: true

require 'rails_helper'
require 'support/auth_helper'
require 'factory_bot_rails'

RSpec.describe 'Requests', type: :request do
  include_examples 'Endpoint parameters'

  it 'requires all necessary params' do
    get '/authorio/auth' # without params
    expect(response).to have_http_status :bad_request
  end

  before :each do
    FactoryBot.create :request
  end

  it 'renders the authorization interface' do
    get '/authorio/auth', params: params
    expect(response.body)
      .to include('Authorio')
  end

  it 'requires valid user URL' do
    params[:me] = 'http://localhost:3000/foo'
    get '/authorio/auth', params: params
    expect(flash[:alert]).to include 'User not found'
  end

  it 'flashes message for incorrect password' do
    get '/authorio/auth', params: params
    post_params[:user][:password] = 'wrong'
    post '/authorio/users/1/authorize', params: post_params
    expect(flash[:alert]).to include('Incorrect password')
  end

  it 'redirects on successful authentication' do
    get '/authorio/auth', params: params
    post '/authorio/users/1/authorize', params: post_params
    expect(response).to redirect_to(/\A#{client_redirect_uri}/)
  end

  it 'redirects to client id when user cancels' do
    get '/authorio/auth', params: params
    post_params[:commit] = 'Cancel'
    post '/authorio/users/1/authorize', params: post_params
    expect(response).to redirect_to params[:client_id]
  end

  it 'verifies correct code' do
    verify_params[:code] = Authorio::Request.first.code
    post '/authorio/auth', params: verify_params
    expect(response).to be_successful
    expect(json['me']).to include('example.com')
  end

  it 'rejects incorrect code' do
    verify_params[:code] = 'wrong'
    post '/authorio/auth', params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it 'rejects client mismatch' do
    verify_params[:client_id] = 'wrong'
    post '/authorio/auth', params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it 'rejects expired codes' do
    req = Authorio::Request.first
    req.created_at = Time.now - 1.day
    req.save
    post '/authorio/auth', params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it 'rejects invalid code_challenge' do
    get '/authorio/auth', params: params
    verify_params[:code_verifier] = 'wrong'
    post '/authorio/auth', params: verify_params
    expect(response).to have_http_status :bad_request
  end

  it 'accepts valid code_verifier' do
    get '/authorio/auth', params: params
    verify_params[:code] = Authorio::Request.first.code
    post '/authorio/auth', params: verify_params
    expect(response).to be_successful
  end

  it 'shows password field if there is no previous session' do
    get '/authorio/auth', params: params
    expect(response.body).to include 'id="user_password"'
  end

  it 'hides password with valid session' do
    Authorio.configuration.local_session_lifetime = 1.day
    get '/authorio/auth', params: params
    post_params[:user][:remember_me] = '1'
    post '/authorio/users/1/authorize', params: post_params
    get '/authorio/auth', params: params
    expect(response.body).not_to include 'id="user_password"'
    post_params[:user][:password] = '' # Should not need password
    post '/authorio/users/1/authorize', params: post_params
    expect(response).to redirect_to(/\A#{client_redirect_uri}/)
  end

  it 'keeps only one (user,client) request' do
    5.times do
      get '/authorio/auth', params: params
    end
    expect(Authorio::Request.count).to eq(1)
  end
end
