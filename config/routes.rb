Authorio::Engine.routes.draw do
	get Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'authorization_interface'
	post Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'verify_code'
	post '/authorize_user', controller: 'auth', action: 'authorize_user'
end
