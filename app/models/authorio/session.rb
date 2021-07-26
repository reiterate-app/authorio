module Authorio
  class Session < ApplicationRecord
    # Implement a session cookie store based on best security practices
    # See: https://paragonie.com/blog/2015/04/secure-authentication-php-with-long-term-persistence
    belongs_to :authorio_user, class_name: "::Authorio::User"

    # 1. Protect against having database stolen by only storing token hashes
    attribute :token   # This will not be persisted in the DB
    has_secure_token

    before_create do
      self.expires_at = Time.now + Authorio.configuration.token_expiration
      self.selector = SecureRandom.hex(12)
      self.hashed_token = Digest::SHA256.hexdigest self.token
    end

    # 2. To guard against timing attacks, we lookup tokens based on a separate selector attribute
    #    and compare them using a secure time-constant comparison method
    def self.find_by_cookie(cookie)
      _selector, _token = cookie.split(':')
      session = find_by selector: _selector
      raise Authorio::Exceptions::SessionReplayAttack.new(session) unless session.matches_cookie?(cookie)
      session
    end

    def matches_cookie?(cookie)
      _selector, _token = cookie.split(':')
      _hashed_token = Digest::SHA256.hexdigest _token
      !expired? && ActiveSupport::SecurityUtils.secure_compare(_hashed_token, hashed_token)
    end
    
    def expired?
      return expires_at < Time.now
    end

    def as_cookie
      "#{selector}:#{token}"
    end
  end
end
