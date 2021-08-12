module Authorio
  class Token < ApplicationRecord
    belongs_to :authorio_user, class_name: "::Authorio::User"
    has_secure_token :auth_token

    validates_presence_of :scope, :client

    before_create do
      self.expires_at = Time.now + Authorio.configuration.token_expiration
    end

    def expired?
      return expires_at < Time.now
    end

    def as_json
      {
        access_token: auth_token,
        expires_in: Authorio.configuration.token_expiration,
        token_type: 'Bearer',
        scope: scope
      }
    end

    def self.create_from_request(req)
      raise Exceptions::InvalidGrant, 'missing scope' if req.scope.blank?
      Token.create(authorio_user: req.authorio_user, scope: req.scope, client: req.client)
    end
  end
end
