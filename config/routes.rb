Authorio::Engine.routes.draw do
	get Authorio.authorization_path, controller: 'auth', action: 'authorization_interface'
end
