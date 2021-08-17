# frozen_string_literal: true

Authorio::Engine.routes.draw do
  root to: 'authorio#index'

  get Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'authorization_interface'
  resources :users, only: %i[show edit update]
  post 'user/authorize', to: 'auth#authorize_user', as: 'authorize_user'
  resource :session, only: %i[new create]
  get 'session', to: 'sessions#destroy', as: 'logout'
  get 'user/(:id)/verify', to: 'users#verify', as: 'verify_user'
  defaults format: :json do
    post Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'send_profile'
    get Authorio.configuration.token_endpoint, controller: 'auth', action: 'verify_token'
    post Authorio.configuration.token_endpoint, controller: 'auth', action: 'issue_token'
  end
end
