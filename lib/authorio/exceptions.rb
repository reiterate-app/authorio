# frozen_string_literal: true

module Authorio
  module Exceptions
    class InvalidGrant < RuntimeError; end

    class InvalidPassword < RuntimeError; end

    class SessionReplayAttack < StandardError
      attr_accessor :session

      def initialize(session)
        super("Session replay attack on user account #{session.authorio_user.id}")
        @session = session
      end
    end

    class UserNotFound < StandardError; end

    class TokenExpired < StandardError; end
  end
end
