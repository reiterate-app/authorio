Authorio::Engine.routes.draw do
	get Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'authorization_interface'
	post Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'send_profile'
	resources :users, only: [:edit, :update] do
		post 'authorize', on: :member, to: 'auth#authorize_user'
	end
	resource :session, only: [:new, :create]
	get 'session' => 'sessions#destroy', as: 'logout'
	get Authorio.configuration.token_endpoint, controller: 'auth', action: 'verify_token'
	post Authorio.configuration.token_endpoint, controller: 'auth', action: 'issue_token'
	root to: 'authorio#index'
end