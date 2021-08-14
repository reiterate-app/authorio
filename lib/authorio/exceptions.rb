# frozen_string_literal: true

module Authorio
  module Exceptions
    class InvalidGrant < RuntimeError; end

    class InvalidPassword < RuntimeError; end

    class SessionReplayAttack < StandardError
      attr_accessor :session

      def initialize(session)
        super
        @session = session
      end
    end

    class UserNotFound < StandardError; end

    class TokenExpired < StandardError; end
  end
end
