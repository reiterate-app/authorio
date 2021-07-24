Authorio::Engine.routes.draw do
	get Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'authorization_interface'
	post Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'send_profile'
	resources :users do
		post 'authorize', on: :member, to: 'auth#authorize_user'
	end
	get Authorio.configuration.token_endpoint, controller: 'auth', action: 'verify_token'
	post Authorio.configuration.token_endpoint, controller: 'auth', action: 'issue_token'
end
