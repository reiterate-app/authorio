module Authorio
	class Configuration

		attr_accessor :authorization_endpoint, :token_endpoint, :mount_point, :token_expiration

		def initialize
			@authorization_endpoint = "auth"
			@token_endpoint = "token"
			@mount_point = "authorio"
			@token_expiration = 4.weeks
		end
	end
end
