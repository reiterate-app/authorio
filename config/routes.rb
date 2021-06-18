require 'byebug'

Authorio::Engine.routes.draw do
	get Authorio.configuration.authorization_endpoint, controller: 'auth', action: 'authorization_interface'
end
