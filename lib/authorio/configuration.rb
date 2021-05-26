module Authorio
	class Configuration

		attr_accessor :authorization_endpoint, :token_endpoint

		def initialize
			@authorization_endpoint = "/auth/"
			@token_endpoint = "/token/"
		end
	end
end
