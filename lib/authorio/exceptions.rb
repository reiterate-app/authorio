module Authorio
	class ClientMismatch < RuntimeError
	end

	class CodeChallengeMismatch < RuntimeError
	end

	class AuthParameterMismatch < RuntimeError
	end

	class StaleRequest < RuntimeError
	end
end
