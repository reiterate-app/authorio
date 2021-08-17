# frozen_string_literal: true

module Authorio
  class Configuration
    attr_accessor :authorization_endpoint, :token_endpoint, :mount_point, :token_expiration,
                  :local_session_lifetime, :multiuser

    def initialize
      @authorization_endpoint = 'auth'
      @token_endpoint = 'token'
      @mount_point = 'authorio'
      @token_expiration = 4.weeks
      @local_session_lifetime = nil
      @multiuser = false
    end
  end
end
