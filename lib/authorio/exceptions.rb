module Authorio
	module Exceptions
		class InvalidGrant < RuntimeError; end
		class InvalidPassword < RuntimeError; end

		class SessionReplayAttack < StandardError
			attr_accessor :session

			def initialize(session)
				@session = session
			end
		end
	end
end
