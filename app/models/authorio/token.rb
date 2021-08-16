# frozen_string_literal: true

module Authorio
  class Token < ApplicationRecord
    belongs_to :authorio_user, class_name: '::Authorio::User'
    has_secure_token :auth_token

    validates_presence_of :scope, :client

    before_create do
      self.expires_at = Time.now + Authorio.configuration.token_expiration
    end

    # The token endpoint can get hit by bots, so short-circut the find if they
    # don't send a bearer token
    def self.find_by_auth_token!(token)
      raise ActiveRecord::RecordNotFound unless token

      find_by! auth_token: token
    end

    def expired?
      expires_at < Time.now
    end

    def as_json
      {
        access_token: auth_token,
        expires_in: Authorio.configuration.token_expiration,
        token_type: 'Bearer',
        scope: scope
      }
    end

    def verification_response
      raise Exceptions::TokenExpired if expired?

      {
        me: authorio_user.profile_path,
        client_id: client,
        scope: scope
      }
    end

    def self.create_from_request(req)
      raise Exceptions::InvalidGrant, 'missing scope' if req.scope.blank?

      Token.create(authorio_user: req.authorio_user, scope: req.scope, client: req.client)
    end
  end
end
