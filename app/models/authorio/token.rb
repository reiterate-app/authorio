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
  end
end
