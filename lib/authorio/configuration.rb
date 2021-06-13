module Authorio
	class Configuration

		attr_accessor :authorization_endpoint, :token_endpoint, :mount_point

		def initialize
			@authorization_endpoint = "auth"
			@token_endpoint = "token"
			@mount_point = "authorio"
		end
	end
end
