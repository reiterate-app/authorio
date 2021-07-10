Authorio::Engine.routes.draw do
	get Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'authorization_interface'
	post Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'send_profile'
	post '/authorize_user', controller: 'auth', action: 'authorize_user'
	get Authorio.configuration.token_endpoint, controller: 'auth', action: 'verify_token'
	post Authorio.configuration.token_endpoint, controller: 'auth', action: 'issue_token'
end
